<script lang="ts">
	interface Props {
		number: number;
		text: string;
		whoSaidIt: string;
		date: string;
	}

	let { number, text, whoSaidIt, date }: Props = $props();
</script>

<div id={`quote-${number}`}>
	<a href={`#quote-${number}`}>#{number}</a>
	<blockquote>
		<p>{text}</p>
	</blockquote>
	<p class="quote-footer">
		—<cite>{whoSaidIt}</cite>,
		<time datetime={date}>{Intl.DateTimeFormat('sv-SE').format(new Date(date))}</time>
	</p>
</div>

<style>
	div {
		border-color: grey;
		box-shadow: 0 4px 2px -2px rgba(0, 0, 0, 0.28);
		border-radius: 5px;
		background-color: #fff4e6;

		background-image: url('/images/quotes.svg');
		background-repeat: no-repeat;
		background-size: 82px;
		background-position: right;
		background-position-y: -16px;

		font-size: 1.4em;
		padding: 10px;
	}

	a {
		display: block;
		opacity: 0.2;
		color: #251e3e;
		margin-right: 5px;
		text-decoration: none;
	}

	a:hover {
		text-decoration: underline;
	}

	blockquote {
		margin: 0;
	}

	blockquote > p {
		font-size: 1.4rem;
		margin-left: 10px;
		padding-top: 10px;
		color: #251e3e;
		font-family: 'Tenor Sans', sans-serif;
	}

	.quote-footer {
		text-align: right;
		font-size: 1.2rem;
		font-family: 'Cormorant Garamond', serif;
		font-style: italic;

		margin: 0;
	}
</style>
