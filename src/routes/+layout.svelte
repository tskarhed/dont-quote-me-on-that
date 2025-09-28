<script lang="ts">
	import favicon from '$lib/assets/favicon.svg';
	import { PUBLIC_SITE_TITLE } from '$env/static/public';

	import { supabase } from '$lib/supabaseClient';
	import { onMount } from 'svelte';

	import { user } from '$lib/stores';

	let userRole = $state<string>('');

	onMount(() => {
		supabase.auth.getUser().then(({ data }) => {
			user.set(data.user ? data.user : null);
		});

		// listen for auth changes
		supabase.auth.onAuthStateChange((_event, session) => {
			user.set(session?.user ? session.user : null);
		});
	});

	async function checkUserRole() {
		const u = $user;
		if (!u) {
			userRole = '';
			return;
		}

		try {
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
		} catch (error) {
			console.error('Error checking user role:', error);
			userRole = 'user';
		}
	}

	$effect(() => {
		if ($user) {
			checkUserRole();
		} else {
			userRole = '';
		}
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
<div id="container">
	<header>
		<div class="header-content">
			<h1>{PUBLIC_SITE_TITLE}</h1>
			{#if userRole === 'admin'}
				<a href="/admin" class="admin-link">Admin</a>
			{/if}
		</div>
	</header>
	<main>
		{@render children?.()}
	</main>
	<footer>
		{#if $user}
			<button onclick={() => supabase.auth.signOut()}>Logga ut</button>
		{/if}
	</footer>
</div>

<style>
	:global(body) {
		background-color: #be9b7b;
		padding: 0;
		margin: 0;
		font-family: 'Cormorant Garamond', serif;
		font-size: 1.2rem;
	}

	#container {
		display: flex;
		flex-direction: column;
		min-height: 100vh;
	}

	main {
		padding: 1rem;
		display: flex;
		flex-direction: column;
		gap: 1rem;

		flex-grow: 1;
	}

	header {
		background-color: #3c2f2f;
		padding: 1rem 0;
		font-family: 'Cormorant Garamond', serif;
	}

	.header-content {
		display: flex;
		justify-content: space-between;
		align-items: center;
		max-width: 1200px;
		margin: 0 auto;
		padding: 0 1rem;
	}

	header h1 {
		color: #fff4e6;
		margin: 0;
		flex: 1;
		text-align: center;
	}

	.admin-link {
		color: #fff4e6;
		text-decoration: none;
		font-size: 1rem;
		padding: 0.5rem 1rem;
		border: 1px solid #fff4e6;
		border-radius: 4px;
		transition: all 0.3s ease;
		flex-shrink: 0;
		margin-left: 1rem;
	}

	.admin-link:hover {
		background-color: #fff4e6;
		color: #3c2f2f;
	}

	@media (max-width: 768px) {
		.header-content {
			flex-direction: column;
			gap: 1rem;
			padding: 0 0.5rem;
		}

		header h1 {
			text-align: center;
			font-size: 1.5rem;
		}

		.admin-link {
			margin-left: 0;
			font-size: 0.8rem;
			padding: 0.4rem 0.8rem;
		}
	}

	@media (max-width: 480px) {
		header h1 {
			font-size: 1.3rem;
		}

		.admin-link {
			font-size: 0.75rem;
			padding: 0.3rem 0.6rem;
		}
	}

	footer {
		padding: 1rem;
		text-align: center;
	}
</style>
