<script lang="ts">
	import { supabase } from '$lib/supabaseClient';
	import { user } from '$lib/stores';
	import { get } from 'svelte/store';
	import type { Quote } from '$lib/types';
	import QuoteComponent from '$lib/components/Quote.svelte';
	import { slide } from 'svelte/transition';

	let quotes = $state<Quote[]>([]);
	let text = $state<string>('');
	let author = $state<string>('');
	let displayAddForm = $state<boolean>(false);
	let isAllowlisted = $state<boolean>(false);
	let userRole = $state<string>('');
	let allowlistError = $state<string>('');
	let isLoading = $state<boolean>(true);
	let isLoadingMore = $state<boolean>(false);
	let currentPage = $state<number>(1);
	let pageSize = $state<number>(50);
	let hasMore = $state<boolean>(true);
	let initialLoadComplete = $state<boolean>(false);

	async function loadQuotes(reset = true, page?: number) {
		if (!isAllowlisted && userRole !== 'admin') return;

		const targetPage = page ?? currentPage;

		if (reset) {
			currentPage = 1;
			quotes = [];
		}

		const offset = (targetPage - 1) * pageSize;

		const { data, error } = await supabase
			.from('quotes')
			.select('*')
			.order('number', { ascending: false })
			.range(offset, offset + pageSize - 1);

		if (error) {
			allowlistError = error.message;
			return;
		}

		const newQuotes = data ?? [];

		if (reset) {
			quotes = newQuotes;
		} else {
			quotes = [...quotes, ...newQuotes];
		}

		// Check if there are more quotes to load
		hasMore = newQuotes.length === pageSize;

		// Mark initial load as complete
		if (reset) {
			initialLoadComplete = true;
		}
	}

	async function checkAllowlistStatus() {
		const u = get(user);
		if (!u) {
			isAllowlisted = false;
			userRole = '';
			isLoading = false;
			return;
		}

		try {
			// Check user role first
			const { data: profileData, error: profileError } = await supabase
				.from('profiles')
				.select('role')
				.eq('id', u.id)
				.maybeSingle();

			if (profileError) {
				console.error('Profile check error:', profileError);
				userRole = 'user';
			} else {
				userRole = profileData?.role || 'user';
			}

			// If user is admin, they don't need to be in allowlist
			if (userRole === 'admin') {
				isAllowlisted = true;
				isLoading = false;
				return;
			}

			// Check if user is in allowlist (only for non-admin users)
			if (!u.email) {
				isAllowlisted = false;
				isLoading = false;
				return;
			}

			const { data: allowlistData, error: allowlistError } = await supabase
				.from('allowlist')
				.select('email')
				.eq('email', u.email);

			if (allowlistError) {
				console.error('Allowlist check error:', allowlistError);
				isAllowlisted = false;
			} else {
				isAllowlisted = allowlistData && allowlistData.length > 0;
			}
		} catch (error) {
			console.error('Error checking allowlist status:', error);
			isAllowlisted = false;
			userRole = 'user';
		} finally {
			isLoading = false;
		}
	}

	async function loadMoreQuotes(event?: Event) {
		if (event) {
			event.preventDefault();
		}

		if (!hasMore || isLoadingMore) return;

		isLoadingMore = true;
		const nextPage = currentPage + 1;
		console.log('Loading more quotes, currentPage:', currentPage, 'nextPage:', nextPage);
		currentPage = nextPage;

		try {
			await loadQuotes(false, nextPage);
		} finally {
			isLoadingMore = false;
		}
	}

	async function addQuote() {
		const u = get(user);
		if (!u || (!isAllowlisted && userRole !== 'admin')) return;

		const { error } = await supabase.from('quotes').insert({
			text,
			author,
			created_by: u.id
		});

		if (error) {
			allowlistError = error.message;
			return;
		}

		text = '';
		author = '';
		loadQuotes();
	}

	function handleSubmit(event: Event) {
		event.preventDefault();
		addQuote();
	}

	$effect(() => {
		if ($user) {
			checkAllowlistStatus();
		} else {
			quotes = [];
			displayAddForm = false;
			isAllowlisted = false;
			userRole = '';
			allowlistError = '';
			isLoading = false;
			currentPage = 1;
			hasMore = true;
			initialLoadComplete = false;
		}
	});

	$effect(() => {
		if ((isAllowlisted || userRole === 'admin') && !isLoading && !initialLoadComplete) {
			loadQuotes();
		}
	});
</script>

{#if $user}
	{#if isLoading}
		<div class="loading">
			<p>Checking access permissions...</p>
		</div>
	{:else if isAllowlisted || userRole === 'admin'}
		{#if displayAddForm}
			<section id="add-quote-form" transition:slide={{ duration: 300 }}>
				<h2>Lägg till citat</h2>
				<p>Datum läggs till automatiskt</p>
				<form onsubmit={handleSubmit}>
					<input name="text" bind:value={text} placeholder="Vad sades" required />
					<input name="author" bind:value={author} placeholder="Vem sade det" required />
					<button type="submit">Lägg till</button>
					<button type="button" onclick={() => (displayAddForm = false)}>Avbryt</button>
				</form>
			</section>
		{:else}
			<button onclick={() => (displayAddForm = !displayAddForm)}> Lägg till citat </button>
		{/if}
	{:else}
		<div class="access-denied">
			<h2>Tillgång begränsad</h2>
			<p>Din e-post ({$user?.email || 'okänd'}) har inte rättighet att se citat.</p>
			<p>Kontakta en administratör för att begära tillgång.</p>
			{#if allowlistError}
				<p class="error-details">Fel: {allowlistError}</p>
			{/if}
		</div>
	{/if}
{:else}
	<p>Du måste vara inloggad för att lägga till citat.</p>
	<a href="/login">Logga in</a>
{/if}

<section id="quotes">
	{#if $user && (isAllowlisted || userRole === 'admin') && !isLoading}
		{#each quotes as q}
			<QuoteComponent whoSaidIt={q.author} date={q.created_at} text={q.text} number={q.number} />
		{/each}

		{#if hasMore && quotes.length > 0}
			<div class="load-more-container">
				<button
					type="button"
					onclick={(e) => loadMoreQuotes(e)}
					disabled={isLoadingMore}
					class="load-more-btn"
				>
					{#if isLoadingMore}
						Laddar...
					{:else}
						↻ Ladda fler
					{/if}
				</button>
			</div>
		{/if}
	{:else if $user && isLoading}
		<div class="loading">
			<p>Loading quotes...</p>
		</div>
	{:else}
		<p>Du måste vara inloggad för att se citat.</p>
	{/if}
</section>

<style>
	#add-quote-form {
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
	}

	#add-quote-form form {
		display: grid;
		grid-template-columns: 1fr 1fr;
		gap: 0.5rem;
	}

	#quotes {
		display: grid;
		gap: 0.5rem;
		grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
		width: 100%;
		max-width: none;
	}
	form input {
		grid-column: span 2;
	}

	button {
		align-self: center;
		max-width: fit-content;
	}

	.error-details {
		color: #d32f2f !important;
		font-style: italic;
		font-size: 1rem;
	}

	.loading {
		text-align: center;
		padding: 2rem;
		color: #666;
	}

	.load-more-container {
		display: flex;
		justify-content: center;
		padding: 2rem;
		grid-column: 1 / -1;
	}

	.load-more-btn:disabled {
		background-color: #6c757d;
		cursor: not-allowed;
	}
</style>
