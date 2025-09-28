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

	async function loadQuotes() {
		if (!isAllowlisted && userRole !== 'admin') return;

		const { data, error } = await supabase
			.from('quotes')
			.select('*')
			.order('number', { ascending: false });

		if (error) {
			allowlistError = error.message;
			return;
		}

		quotes = data ?? [];
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
				.single();

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
		}
	});

	$effect(() => {
		if ((isAllowlisted || userRole === 'admin') && !isLoading) {
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
			<p>Din e-post ({$user.email}) har inte rättighet att se citat.</p>
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
		font-size: 0.9rem;
	}

	.loading {
		text-align: center;
		padding: 2rem;
		color: #666;
	}
</style>
