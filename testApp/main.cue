package main

import (
	"encoding/json"
	"strings"

	"alpha.dagger.io/dagger"
	"alpha.dagger.io/os"
	"alpha.dagger.io/netlify"
	multistage "github.com/grouville/dagger-multistaging/multistage"
)

gitRepo: {
	// Git remote
	remote: string | *"origin"
	// Git subdir
	subdir: string | *"/"
	// Git name
	name: string
	// Git email
	email: string
}

auth: {
	// Git Auth Token
	git: dagger.#Secret @dagger(input)
	// Netlify Auth Token
	netlify: dagger.#Secret @dagger(input)
}

// Reference provider
provider: *"github" | "gitlab"
// Reference refType
refType: *"pr" | "branch" | "tag"
// Source directory
source: dagger.#Artifact @dagger(input)


refs: {
	multistage.#References & {
		repository: {
			authToken: auth.git
			"provider": provider
			"refType": refType
			"source": source
		}
		email: gitRepo.email
		name: gitRepo.name
	}
}.out

deployments: multistage.#Multistaging & {
	checkouts: {
		multistage.#Checkouts & {
			"refs": json.Unmarshal(refs)
			authToken: auth.git
		}
	}.out

	#template: {
		// Implement the standard #SimpleApp
		name: string
		source: dagger.#Artifact

		// App-specific deployment config goes here:
		site: netlify.#Site & {
			account: token: auth.netlify
			contents: os.#Dir & {
				from: source
				path: "./src"
			}
			"name": strings.Replace(
				strings.Replace(name, "/", "-", -1),
			".", "_", -1)
		}
	}
}
