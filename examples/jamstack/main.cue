package jamstack

import (
	"alpha.dagger.io/dagger"
	"alpha.dagger.io/netlify"
	"alpha.dagger.io/js/yarn"

	"github.com/grouville/dagger-microstage/microstage"
)

// Source repository
repository: dagger.#Artifact @dagger(input)

// Netlify PAT
netlifyAccount: netlify.#Account & {
	name: "guillaume-derouville"
}

// Name of netlify app
ref: "testNetlifyDebug"

deployment: {
	microstage.#Microstaging & {
		checkout: repository
		prettyName: "pr-okioo-\(ref)"

		#template: {
			// Implement the standard #SimpleApp
			// to access its fields locally
			name: string

			// Build the docs website
			docs: yarn.#Package & {
				source:   checkout
				cwd:      "website/"
				buildDir: "website/build"
				script: "build:withoutAuth"
				secrets: {
					OAUTH_ENABLE:                   dagger.#Secret @dagger(input)
					REACT_APP_OAUTH_SCOPE:          dagger.#Secret @dagger(input)
					REACT_APP_GITHUB_AUTHORIZE_URI: dagger.#Secret @dagger(input)
					REACT_APP_DAGGER_SITE_URI:      dagger.#Secret @dagger(input)
					REACT_APP_API_PROXY_ENABLE:     dagger.#Secret @dagger(input)
					REACT_APP_CLIENT_ID: 			dagger.#Secret @dagger(input)
					REACT_APP_CLIENT_SECRET: 		dagger.#Secret @dagger(input)
				}
			}

			// Deploy the docs website
			site: netlify.#Site & {
				"name":   name
				account: netlifyAccount
				contents: docs.build
			}
		}
	}
}.out
