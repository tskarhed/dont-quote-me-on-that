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

	async function loadQuotes() {
		const { data } = await supabase
			.from('quotes')
			.select('*')
			.order('number', { ascending: false });
		quotes = data ?? [];
	}

	async function addQuote() {
		const u = get(user);
		if (!u) return;

		await supabase.from('quotes').insert({
			text,
			author,
			created_by: u.id
		});
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
			loadQuotes();
		} else {
			quotes = [];
			displayAddForm = false;
		}
	});
</script>

{#if $user}
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
	<p>Du måste vara inloggad för att lägga till citat.</p>
	<a href="/login">Logga in</a>
{/if}

<section id="quotes">
	{#if $user}
		{#each quotes as q}
			<QuoteComponent whoSaidIt={q.author} date={q.created_at} text={q.text} number={q.number} />
		{/each}
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
</style>
