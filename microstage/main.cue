package microstage

import (
	"alpha.dagger.io/dagger"
)

#Microstaging: {
	// Source code checkout
	checkout: dagger.#Artifact
	prettyName: string

	// Common configuration template for deployment
	// (app-specifig deployment logic goes here)
	#template: {
		// source to deploy
		source: dagger.#Artifact
		// Unique name (for naming app-specific resources)
		name: string
		...
	}

	// Deploy checkout
	// Live deployment (one per checkout)
	out: {
		#template & {
			source: checkout
			"name": prettyName
		}
	}
}

// // Required fields for the callback
// #SimpleApp: {
// 	// source to deploy
// 	source: dagger.#Artifact
// 	// Unique name (for naming app-specific resources)
// 	name: string
// }