<script lang="ts">
	import favicon from '$lib/assets/favicon.svg';
	import { PUBLIC_SITE_TITLE } from '$env/static/public';

	import { supabase } from '$lib/supabaseClient';
	import { onMount } from 'svelte';

	import { user } from '$lib/stores';

	onMount(() => {
		supabase.auth.getUser().then(({ data }) => {
			user.set(data.user ? data.user : null);
		});

		// listen for auth changes
		supabase.auth.onAuthStateChange((_event, session) => {
			user.set(session?.user ? session.user : null);
		});
	});

	let { children } = $props();
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
	<link rel="stylesheet" href="/styles.css" />
	<link
		href="https://fonts.googleapis.com/css?family=Cormorant+Garamond&display=swap"
		rel="stylesheet"
	/>
	<link href="https://fonts.googleapis.com/css?family=Tenor+Sans&display=swap" rel="stylesheet" />
	<link href="https://fonts.googleapis.com/css?family=Roboto&display=swap" rel="stylesheet" />
</svelte:head>
<header>
	<h1>{PUBLIC_SITE_TITLE}</h1>
</header>
<main>
	{@render children?.()}

	<footer>
		{#if $user}
			<button onclick={() => supabase.auth.signOut()}>Logga ut</button>
		{/if}
	</footer>
</main>

<style>
	:global(body) {
		background-color: #be9b7b;
		padding: 0;
		margin: 0;
		font-family: 'Cormorant Garamond', serif;
		font-size: 1.2rem;
	}

	main {
		padding: 1rem;
	}

	header {
		background-color: #3c2f2f;
		padding: 1rem 0;
		font-family: 'Cormorant Garamond', serif;
		text-align: center;
	}

	header h1 {
		color: #fff4e6;
		margin: 0;
	}
</style>
