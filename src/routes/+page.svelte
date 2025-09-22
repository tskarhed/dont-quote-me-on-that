<script lang="ts">
	import { supabase } from '$lib/supabaseClient';
	import { user } from '$lib/stores';
	import { get } from 'svelte/store';

	type Quote = {
		id: number;
		number: number;
		text: string;
		author: string;
		created_at: string;
		created_by: string;
	};

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

	loadQuotes();
</script>

<h1>Quotes</h1>
{#if $user}
	<button onclick={() => (displayAddForm = !displayAddForm)}>
		{displayAddForm ? 'Cancel' : 'Add a Quote'}
	</button>
	{#if displayAddForm}
		<input bind:value={text} placeholder="What was said" />
		<input bind:value={author} placeholder="Who said it" />
		<button onclick={addQuote}>Add</button>
	{/if}
{:else}
	<p>You must be logged in to add quotes.</p>
{/if}
<ul>
	{#each quotes as q}
		<li>#{q.number} — "{q.text}" (by {q.author})</li>
	{/each}
</ul>
