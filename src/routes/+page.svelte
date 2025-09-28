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
	{#if userRole === 'admin'}
		<div class="admin-notice">
			<p>Welcome, admin! <a href="/admin">Go to Admin Panel</a></p>
		</div>
	{/if}

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
			<h2>Access Restricted</h2>
			<p>Your email ({$user.email}) is not on the allowlist.</p>
			<p>Please contact an administrator to request access.</p>
			{#if allowlistError}
				<p class="error-details">Error: {allowlistError}</p>
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
	{:else if $user && !isAllowlisted && userRole !== 'admin' && !isLoading}
		<div class="access-denied">
			<h3>Cannot View Quotes</h3>
			<p>You must be on the allowlist to view quotes.</p>
			<p>Your email ({$user.email}) is not currently authorized.</p>
			{#if allowlistError}
				<p class="error-details">Error: {allowlistError}</p>
			{/if}
		</div>
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
		grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
	}

	form input {
		grid-column: span 2;
	}
	
	button {
		width: 100%;
	}

	.admin-notice {
		background-color: #e3f2fd;
		border: 1px solid #2196f3;
		border-radius: 8px;
		padding: 1rem;
		margin: 1rem 0;
		text-align: center;
	}

	.admin-notice a {
		color: #1976d2;
		text-decoration: none;
		font-weight: 500;
	}

	.admin-notice a:hover {
		text-decoration: underline;
	}

	.access-denied {
		background-color: #ffebee;
		border: 1px solid #f44336;
		border-radius: 8px;
		padding: 1rem;
		margin: 1rem 0;
		text-align: center;
	}

	.access-denied h2,
	.access-denied h3 {
		color: #d32f2f;
		margin-top: 0;
	}

	.access-denied p {
		color: #666;
		margin: 0.5rem 0;
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
