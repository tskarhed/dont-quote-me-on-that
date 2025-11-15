import adapter from '@sveltejs/adapter-static';
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';

/** @type {import('@sveltejs/kit').Config} */
const config = {
	// Consult https://svelte.dev/docs/kit/integrations
	// for more information about preprocessors
	preprocess: vitePreprocess(),

	kit: {
		adapter: adapter({
			pages: 'build',
			assets: 'build',
			fallback: undefined,
			precompress: false,
			strict: true
		}),
		paths: {
			// Base path is set via BASE_PATH environment variable
			// For custom domains, set BASE_PATH to '' (empty string)
			// For project pages, set BASE_PATH to '/repo-name'
			base: process.env.BASE_PATH || ''
		}
	}
};

export default config;
