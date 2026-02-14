<script lang="ts">
	import Modal from "../common/Modal.svelte";

	import { WEB_UI_VERSION } from "$lib/constants";
	import toast from "svelte-french-toast";
	import { onMount } from "svelte";
	import { info, models, settings } from "$lib/stores";
	import { splitStream } from "$lib/utils";
	import Advanced from "./Settings/Advanced.svelte";

	export let show = false;

	const saveSettings = async (updated) => {
		console.log(updated);
		await settings.set({ ...$settings, ...updated });
		localStorage.setItem("settings", JSON.stringify($settings));
		toast.success("Settings saved successfully");
	};

	let selectedTab = "general";

	// General
	let theme = "dark";
	let notificationEnabled = false;

	// Advanced
	let requestFormat = "";
	let options = {
		// Advanced
		seed: 0,
		temperature: "",
		repeat_penalty: "",
		repeat_last_n: "",
		mirostat: "",
		mirostat_eta: "",
		mirostat_tau: "",
		top_k: "",
		top_p: "",
		stop: "",
		tfs_z: "",
		num_ctx: ""
	};

	// Models configuration
	let modelsConfig = [
		{
			id: "1",
			name: "nanobot",
			url: "http://127.0.0.1:5679/v1",
			apiKey: "",
			isDefault: true
		}
	];

	// UI state
	let expandedModelId = null;
	let editingModel = null;
	let showEditModal = false;
	let showDeleteConfirm = false;
	let modelToDelete = null;

	const toggleTheme = async () => {
		if (theme === "dark") {
			theme = "light";
		} else {
			theme = "dark";
		}

		localStorage.theme = theme;

		document.documentElement.classList.remove(theme === "dark" ? "light" : "dark");
		document.documentElement.classList.add(theme);
	};

	const toggleRequestFormat = async () => {
		if (requestFormat === "") {
			requestFormat = "json";
		} else {
			requestFormat = "";
		}

		saveSettings({ requestFormat: requestFormat !== "" ? requestFormat : undefined });
	};

	const addModel = () => {
		modelsConfig.push({
			id: Date.now().toString(),
			name: "New Model",
			url: "",
			apiKey: "",
			isDefault: false
		});
	};

	const removeModel = (id) => {
		if (modelsConfig.length > 1) {
			modelToDelete = id;
			showDeleteConfirm = true;
		} else {
			toast.error("At least one model is required");
		}
	};

	const confirmDeleteModel = () => {
		if (modelToDelete) {
			modelsConfig = modelsConfig.filter(model => model.id !== modelToDelete);
			// If the deleted model was the default, set the first model as default
			if (modelsConfig.length > 0 && !modelsConfig.some(m => m.isDefault)) {
				modelsConfig[0].isDefault = true;
			}
			showDeleteConfirm = false;
			modelToDelete = null;
			toast.success("Model deleted successfully");
		}
	};

	const cancelDeleteModel = () => {
		showDeleteConfirm = false;
		modelToDelete = null;
	};

	const editModel = (model) => {
		editingModel = { ...model };
		showEditModal = true;
	};

	const saveEditedModel = () => {
		if (editingModel) {
			const index = modelsConfig.findIndex(m => m.id === editingModel.id);
			if (index !== -1) {
				modelsConfig[index] = { ...editingModel };
				// If this model is set as default, ensure others are not
				if (editingModel.isDefault) {
					modelsConfig.forEach((m, i) => {
						if (i !== index) {
							m.isDefault = false;
						}
					});
				}
				showEditModal = false;
				editingModel = null;
				toast.success("Model updated successfully");
			}
		}
	};

	const cancelEditModel = () => {
		showEditModal = false;
		editingModel = null;
	};

	const toggleModelExpanded = (modelId) => {
		expandedModelId = expandedModelId === modelId ? null : modelId;
	};

	onMount(() => {
		let settings = JSON.parse(localStorage.getItem("settings") ?? "{}");
		console.log(settings);

		theme = localStorage.theme ?? "dark";
		notificationEnabled = settings.notificationEnabled ?? false;

		requestFormat = settings.requestFormat ?? "";

		options.seed = settings.seed ?? 0;
		options.temperature = settings.temperature ?? "";
		options.repeat_penalty = settings.repeat_penalty ?? "";
		options.top_k = settings.top_k ?? "";
		options.top_p = settings.top_p ?? "";
		options.num_ctx = settings.num_ctx ?? "";
		options = { ...options, ...settings.options };

		// Load models configuration
		if (settings.modelsConfig && Array.isArray(settings.modelsConfig)) {
			modelsConfig = settings.modelsConfig.map((model, index) => ({
				...model,
				isDefault: model.isDefault ?? (index === 0)
			}));
		}
	});
</script>

<Modal bind:show>
	<div>
		<div class=" flex justify-between dark:text-gray-300 px-5 py-4">
			<div class=" text-lg font-medium self-center">Settings</div>
			<button
				class="self-center"
				on:click={() => {
					show = false;
				}}
			>
				<svg
					xmlns="http://www.w3.org/2000/svg"
					viewBox="0 0 20 20"
					fill="currentColor"
					class="w-5 h-5"
				>
					<path
						d="M6.28 5.22a.75.75 0 00-1.06 1.06L8.94 10l-3.72 3.72a.75.75 0 101.06 1.06L10 11.06l3.72 3.72a.75.75 0 101.06-1.06L11.06 10l3.72-3.72a.75.75 0 00-1.06-1.06L10 8.94 6.28 5.22z"
					/>
					</svg>
			</button>
		</div>
		<hr class=" dark:border-gray-800" />

		<div class="flex flex-col md:flex-row w-full p-4 md:space-x-4">
			<div
				class="tabs flex flex-row overflow-x-auto space-x-1 md:space-x-0 md:space-y-1 md:flex-col flex-1 md:flex-none md:w-40 dark:text-gray-200 text-xs text-left mb-3 md:mb-0"
			>
				<button
					class="px-2.5 py-2.5 min-w-fit rounded-lg flex-1 md:flex-none flex text-right transition {selectedTab ===
					'general'
						? 'bg-gray-200 dark:bg-gray-700'
						: ' hover:bg-gray-300 dark:hover:bg-gray-800'}"
					on:click={() => {
						selectedTab = "general";
					}}
				>
					<div class=" self-center mr-2">
						<svg
							xmlns="http://www.w3.org/2000/svg"
							viewBox="0 0 20 20"
							fill="currentColor"
							class="w-4 h-4"
						>
							<path
								fill-rule="evenodd"
									d="M8.34 1.804A1 1 0 019.32 1h1.36a1 1 0 01.98.804l.295 1.473c.497.144.971.342 1.416.587l1.25-.834a1 1 0 011.262.125l.962.962a1 1 0 01.125 1.262l-.834 1.25c.245.445.443.919.587 1.416l1.473.294a1 1 0 01.804.98v1.361a1 1 0 01-.804.98l-1.473.295a6.95 6.95 0 01-.587 1.416l.834 1.25a1 1 0 01-.125 1.262l-.962.962a1 1 0 01-1.262.125l-1.25-.834a6.953 6.953 0 01-1.416.587l-.294 1.473a1 1 0 01-.98.804H9.32a1 1 0 01-.98-.804l-.295-1.473a6.957 6.957 0 01-1.416-.587l-1.25.834a1 1 0 01-1.262-.125l-.962-.962a1 1 0 01-.125-1.262l.834-1.25a6.957 6.957 0 01-.587-1.416l-1.473-.294A1 1 0 011 10.68V9.32a1 1 0 01.804-.98l1.473-.295c.144-.497.342-.971.587-1.416l-.834-1.25a1 1 0 01.125-1.262l.962-.962A1 1 0 015.38 3.03l1.25.834a6.957 6.957 0 011.416-.587l.294-1.473zM13 10a3 3 0 11-6 0 3 3 0 016 0z"
									clip-rule="evenodd"
									/>
								</svg>
						</div>
					<div class=" self-center">General</div>
				</button>

				<button
					class="px-2.5 py-2.5 min-w-fit rounded-lg flex-1 md:flex-none flex text-right transition {selectedTab ===
					'advanced'
						? 'bg-gray-200 dark:bg-gray-700'
						: ' hover:bg-gray-300 dark:hover:bg-gray-800'}"
					on:click={() => {
						selectedTab = "advanced";
					}}
				>
					<div class=" self-center mr-2">
						<svg
							xmlns="http://www.w3.org/2000/svg"
							viewBox="0 0 20 20"
							fill="currentColor"
							class="w-4 h-4"
						>
							<path
								d="M17 2.75a.75.75 0 00-1.5 0v5.5a.75.75 0 001.5 0v-5.5zM17 15.75a.75.75 0 00-1.5 0v1.5a.75.75 0 001.5 0v-1.5zM3.75 15a.75.75 0 01.75.75v1.5a.75.75 0 01-1.5 0v-1.5a.75.75 0 01.75-.75zM4.5 2.75a.75.75 0 00-1.5 0v5.5a.75.75 0 001.5 0v-5.5zM10 11a.75.75 0 01.75.75v5.5a.75.75 0 01-1.5 0v-5.5A.75.75 0 0110 11zM10.75 2.75a.75.75 0 00-1.5 0v1.5a.75.75 0 001.5 0v-1.5zM10 6a2 2 0 100 4 2 2 0 000-4zM3.75 10a2 2 0 100 4 2 2 0 000-4zM16.25 10a2 2 0 100 4 2 2 0 000-4z"
								/>
								</svg>
						</div>
					<div class=" self-center">Advanced</div>
				</button>

				<button
					class="px-2.5 py-2.5 min-w-fit rounded-lg flex-1 md:flex-none flex text-right transition {selectedTab ===
					'models'
						? 'bg-gray-200 dark:bg-gray-700'
						: ' hover:bg-gray-300 dark:hover:bg-gray-800'}"
					on:click={() => {
						selectedTab = "models";
					}}
				>
					<div class=" self-center mr-2">
						<svg
							xmlns="http://www.w3.org/2000/svg"
							viewBox="0 0 20 20"
							fill="currentColor"
							class="w-4 h-4"
						>
							<path
								fill-rule="evenodd"
									d="M10 1c3.866 0 7 1.79 7 4s-3.134 4-7 4-7-1.79-7-4 3.134-4 7-4zm5.694 8.13c.464-.264.91-.583 1.306-.952V10c0 2.21-3.134 4-7 4s-7-1.79-7-4V8.178c.396.37.842.688 1.306.953C5.838 10.006 7.854 10.5 10 10.5s4.162-.494 5.694-1.37zM3 13.179V15c0 2.21 3.134 4 7 4s7-1.79 7-4v-1.822c-.396.37-.842.688-1.306.953-1.532.875-3.548 1.369-5.694 1.369s-4.162-.494-5.694-1.37A7.009 7.009 0 013 13.179z"
									clip-rule="evenodd"
									/>
								</svg>
						</div>
					<div class=" self-center">Models</div>
				</button>
			</div>
			<div class="flex-1 md:min-h-[340px]">
				{#if selectedTab === "general"}
					<div class="flex flex-col space-y-3">
						<div>
							<div class=" mb-1 text-sm font-medium">WebUI Settings</div>

							<div class=" py-0.5 flex w-full justify-between">
								<div class=" self-center text-xs font-medium">Theme</div>

								<button
									class="p-1 px-3 text-xs flex rounded transition"
									on:click={() => {
										toggleTheme();
									}}
								>
									{#if theme === "dark"}
										<svg
											xmlns="http://www.w3.org/2000/svg"
											viewBox="0 0 20 20"
											fill="currentColor"
											class="w-4 h-4"
										>
											<path
												fill-rule="evenodd"
													d="M7.455 2.004a.75.75 0 01.26.77 7 7 0 009.958 7.967.75.75 0 011.067.853A8.5 8.5 0 116.647 1.921a.75.75 0 01.808.083z"
													clip-rule="evenodd"
													/>
												</svg>

										<span class="ml-2 self-center"> Dark </span>
									{:else}
										<svg
											xmlns="http://www.w3.org/2000/svg"
											viewBox="0 0 20 20"
											fill="currentColor"
											class="w-4 h-4 self-center"
										>
											<path
												d="M10 2a.75.75 0 01.75.75v1.5a.75.75 0 01-1.5 0v-1.5A.75.75 0 0110 2zM10 15a.75.75 0 01.75.75v1.5a.75.75 0 01-1.5 0v-1.5A.75.75 0 0110 15zM10 7a3 3 0 100 6 3 3 0 000-6zM15.657 5.404a.75.75 0 10-1.06-1.06l-1.061 1.06a.75.75 0 001.06 1.06l1.06-1.06zM6.464 14.596a.75.75 0 10-1.06-1.06l-1.06 1.06a.75.75 0 001.06 1.06l1.06-1.06zM18 10a.75.75 0 01-.75.75h-1.5a.75.75 0 010-1.5h1.5A.75.75 0 0118 10zM5 10a.75.75 0 01-.75.75h-1.5a.75.75 0 010-1.5h1.5A.75.75 0 015 10zM14.596 15.657a.75.75 0 001.06-1.06l-1.06-1.061a.75.75 0 10-1.06 1.06l1.06 1.06zM5.404 6.464a.75.75 0 001.06-1.06l-1.06-1.06a.75.75 0 10-1.061 1.06l1.06 1.06z"
											/>
											</svg>
										<span class="ml-2 self-center"> Light </span>
									{/if}
								</button>
							</div>
						</div>

						<hr class=" dark:border-gray-700" />

						<div class="flex justify-end pt-3 text-sm font-medium">
							<button
								class=" px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-gray-100 transition rounded"
								on:click={() => {
									show = false;
								}}
							>
								Save
							</button>
						</div>
					</div>
				{:else if selectedTab === "advanced"}
					<div class="flex flex-col h-full justify-between text-sm">
						<div class=" space-y-3 pr-1.5 overflow-y-scroll max-h-72">
							<div class=" text-sm font-medium">Parameters</div>

							<Advanced bind:options />
							<hr class=" dark:border-gray-700" />

							<div>
								<div class=" py-1 flex w-full justify-between">
									<div class=" self-center text-sm font-medium">Request Mode</div>

									<button
										class="p-1 px-3 text-xs flex rounded transition"
										on:click={() => {
											toggleRequestFormat();
										}}
									>
										{#if requestFormat === ""}
											<span class="ml-2 self-center"> Default </span>
										{:else if requestFormat === "json"}
											<span class="ml-2 self-center"> JSON </span>
										{/if}
									</button>
								</div>
							</div>
						</div>

						<div class="flex justify-end pt-3 text-sm font-medium">
							<button
								class=" px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-gray-100 transition rounded"
								on:click={() => {
									saveSettings({
										options: {
											seed: (options.seed !== 0 ? options.seed : undefined) ?? undefined,
											stop: options.stop !== "" ? options.stop : undefined,
											temperature: options.temperature !== "" ? options.temperature : undefined,
											repeat_penalty:
												options.repeat_penalty !== "" ? options.repeat_penalty : undefined,
											repeat_last_n:
												options.repeat_last_n !== "" ? options.repeat_last_n : undefined,
											mirostat: options.mirostat !== "" ? options.mirostat : undefined,
											mirostat_eta: options.mirostat_eta !== "" ? options.mirostat_eta : undefined,
											mirostat_tau: options.mirostat_tau !== "" ? options.mirostat_tau : undefined,
											top_k: options.top_k !== "" ? options.top_k : undefined,
											top_p: options.top_p !== "" ? options.top_p : undefined,
											tfs_z: options.tfs_z !== "" ? options.tfs_z : undefined,
											num_ctx: options.num_ctx !== "" ? options.num_ctx : undefined
										}
									});
									show = false;
								}}
							>
								Save
							</button>
						</div>
					</div>
				{:else if selectedTab === "models"}
					<div class="flex flex-col space-y-3 text-sm mb-10">
						<div>
							<div class=" mb-2.5 text-sm font-medium">Models Configuration</div>
							<div class="text-xs text-gray-400 dark:text-gray-500 mb-4">
								Configure multiple models with different URLs and API keys (all following OpenAI interface specification)
							</div>

							{#each modelsConfig as model, index}
								<div class="border dark:border-gray-700 rounded-lg mb-3 overflow-hidden">
									<button
										class="w-full flex justify-between items-center p-3 text-left"
										on:click={() => toggleModelExpanded(model.id)}
									>
										<div class="font-medium">
											{model.name}
											{#if model.isDefault}
												<span class="ml-2 bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200 text-xs px-2 py-0.5 rounded">
													Default
												</span>
											{/if}
										</div>
										<svg
											xmlns="http://www.w3.org/2000/svg"
											viewBox="0 0 20 20"
											fill="currentColor"
											class={`w-4 h-4 transition-transform ${expandedModelId === model.id ? 'transform rotate-180' : ''}`}
										>
											<path
												d="M5.23 7.21a.75.75 0 011.06.02L10 11.168l3.71-3.938a.75.75 0 111.08 1.04l-4.25 4.5a.75.75 0 01-1.08 0l-4.25-4.5a.75.75 0 01.02-1.06z"
											/>
											</svg>
									</button>

									{#if expandedModelId === model.id}
										<div class="p-3 border-t dark:border-gray-700">
											<div class="flex justify-between items-center mb-3">
												<div class="text-sm text-gray-500 dark:text-gray-400">
													URL: {model.url}
													{#if model.apiKey}
														<span class="ml-2">• API Key: Set</span>
													{/if}
												</div>
												<div class="flex space-x-2">
													<button
														class="text-blue-500 hover:text-blue-700 px-2 py-1 text-xs rounded"
														on:click={() => editModel(model)}
													>
														Edit
													</button>
													{#if modelsConfig.length > 1}
														<button
															class="text-red-500 hover:text-red-700 px-2 py-1 text-xs rounded"
															on:click={() => removeModel(model.id)}
														>
															Delete
														</button>
													{/if}
												</div>
											</div>
										</div>
									{/if}
								</div>
							{/each}

							<!-- Edit Model Modal -->
							{#if showEditModal && editingModel}
								<div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
									<div class="bg-white dark:bg-gray-800 rounded-lg p-4 max-w-md w-full">
										<div class="flex justify-between items-center mb-4">
											<h3 class="font-medium">Edit Model</h3>
											<button
												on:click={cancelEditModel}
												class="text-gray-400 hover:text-gray-600 dark:text-gray-500 dark:hover:text-gray-300"
											>
												<svg
													xmlns="http://www.w3.org/2000/svg"
													viewBox="0 0 20 20"
													fill="currentColor"
													class="w-5 h-5"
												>
													<path
														d="M6.28 5.22a.75.75 0 00-1.06 1.06L8.94 10l-3.72 3.72a.75.75 0 101.06 1.06L10 11.06l3.72 3.72a.75.75 0 101.06-1.06L11.06 10l3.72-3.72a.75.75 0 00-1.06-1.06L10 8.94 6.28 5.22z"
													/>
													</svg>
												</button>
										</div>
										<div class="space-y-4">
											<div>
												<label class="block text-xs font-medium mb-1">Model Name</label>
												<input
													class="w-full rounded py-2 px-4 text-sm dark:text-gray-300 dark:bg-gray-700 outline-none"
													placeholder="Enter model name"
													bind:value={editingModel.name}
												/>
											</div>
											<div>
												<label class="block text-xs font-medium mb-1">Server URL</label>
												<input
													class="w-full rounded py-2 px-4 text-sm dark:text-gray-300 dark:bg-gray-700 outline-none"
													placeholder="Enter server URL (e.g. http://localhost:11434/api)"
													bind:value={editingModel.url}
												/>
											</div>
											<div>
												<label class="block text-xs font-medium mb-1">API Key</label>
												<input
													class="w-full rounded py-2 px-4 text-sm dark:text-gray-300 dark:bg-gray-700 outline-none"
													placeholder="Enter API key (if required)"
													bind:value={editingModel.apiKey}
												/>
											</div>
											<div class="flex items-center">
												<input
													type="checkbox"
													id="defaultModel"
													bind:checked={editingModel.isDefault}
													class="mr-2"
												/>
												<label for="defaultModel" class="text-sm">Set as default model</label>
											</div>
										</div>
										<div class="flex justify-end space-x-2 mt-4">
											<button
												class="px-3 py-1 text-sm border dark:border-gray-600 rounded hover:bg-gray-100 dark:hover:bg-gray-700"
												on:click={cancelEditModel}
											>
												Cancel
											</button>
											<button
												class="px-3 py-1 text-sm bg-emerald-600 hover:bg-emerald-700 text-white rounded"
												on:click={saveEditedModel}
											>
												Save
											</button>
										</div>
									</div>
								</div>
							{/if}

							<!-- Delete Confirmation Modal -->
							{#if showDeleteConfirm}
								<div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
									<div class="bg-white dark:bg-gray-800 rounded-lg p-4 max-w-sm w-full">
										<div class="mb-4">
											<h3 class="font-medium mb-2">Confirm Delete</h3>
											<p class="text-sm text-gray-600 dark:text-gray-400">
												Are you sure you want to delete this model? This action cannot be undone.
											</p>
										</div>
										<div class="flex justify-end space-x-2">
											<button
												class="px-3 py-1 text-sm border dark:border-gray-600 rounded hover:bg-gray-100 dark:hover:bg-gray-700"
												on:click={cancelDeleteModel}
											>
												Cancel
											</button>
											<button
												class="px-3 py-1 text-sm bg-red-600 hover:bg-red-700 text-white rounded"
												on:click={confirmDeleteModel}
											>
												Delete
											</button>
										</div>
									</div>
								</div>
							{/if}

							<button
								class="w-full mt-3 px-3 py-2 bg-emerald-600 hover:bg-emerald-700 text-gray-100 rounded transition flex items-center justify-center"
								on:click={addModel}
							>
								<svg
									xmlns="http://www.w3.org/2000/svg"
									viewBox="0 0 20 20"
									fill="currentColor"
									class="w-4 h-4 mr-2"
								>
									<path
										d="M8 9a3 3 0 100-6 3 3 0 000 6zM8 11a6 6 0 016 6H2a6 6 0 016-6zM16 7a1 1 0 10-2 0v1h-1a1 1 0 100 2h1v1a1 1 0 102 0v-1h1a1 1 0 100-2h-1V7z"
									/>
									</svg>
								Add Model
							</button>
						</div>

						<div class="flex justify-end pt-3 text-sm font-medium">
							<button
								class=" px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-gray-100 transition rounded"
								on:click={() => {
									saveSettings({ modelsConfig });
									show = false;
								}}
							>
								Save
							</button>
						</div>
					</div>
				{/if}
			</div>
		</div>
	</div>
</Modal>

<style>
	input::-webkit-outer-spin-button,
	input::-webkit-inner-spin-button {
		/* display: none; <- Crashes Chrome on hover */
		-webkit-appearance: none;
		margin: 0; /* <-- Apparently some margin are still there even though it's hidden */
	}

	.tabs::-webkit-scrollbar {
		display: none; /* for Chrome, Safari and Opera */
	}

	.tabs {
		-ms-overflow-style: none; /* IE and Edge */
		scrollbar-width: none; /* Firefox */
	}

	input[type="number"] {
		-moz-appearance: textfield; /* Firefox */
	}
</style>