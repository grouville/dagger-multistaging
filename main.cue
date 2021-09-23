package microstaging

import (
	"alpha.dagger.io/dagger"
	"alpha.dagger.io/netlify"
)

multistageDeployment: {
	// Git Auth Token
	gitAuthToken: dagger.#Input & { dagger.#Secret }

	// Include inputs of `#Deployment` child definitions
	deploymentInputs: {
		netlifyAccount: netlify.#Account
	}

	// Collect references
	refs: #References & {
		repository: authToken: gitAuthToken
	}

	// Deploy on all refs
	deployments: #MultiDeployment & {
		"refs": refs.out
		"authToken": gitAuthToken
	}
}
