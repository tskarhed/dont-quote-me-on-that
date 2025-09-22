<script lang="ts">
	import favicon from '$lib/assets/favicon.svg';

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
</svelte:head>

{@render children?.()}
