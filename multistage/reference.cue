package multistage

import(
	"alpha.dagger.io/dagger"
	"alpha.dagger.io/git"
	"alpha.dagger.io/os"
)

#References: {
	repository: {
		// Git Auth Token
		authToken: *null | dagger.#Secret
		
		// Repo's version control provider
		provider: *"github" | "gitlab"

		// Ref type
		refType: *"pr" | "branch" | "tag"
		
		// Remote Name
		remote: *"origin" | string

		// Git repository to extract reference from
		source: dagger.#Artifact
	}

	// Username
	name: string

	// Email
	email: string

	// Execute and extract from
	_ctr: os.#Container & {
		image: git.#Image & {
			package: jo: "=~1.4"
		}
		command: #Command
		dir: "/repo1"
		mount: "/repo1": from: repository.source
		env: {
			USER_NAME:		name
			USER_EMAIL:		email
			REMOTE: 		repository.remote
			if repository.refType == "pr" && repository.provider == "gitlab" {
				REF:		"merge-requests/*/head"
			}
			if repository.refType == "pr" && repository.provider == "github" {
				REF:		"pull/*/head"
			}
			if repository.refType == "branch" {
				REF:		"refs/heads/*"
			}
			if repository.refType == "tags" {
				REF:		"refs/tags"
			}
		}
		if repository.authToken != null {
			env: GIT_ASKPASS: "/get_authToken"
			files: "/get_authToken": {
				content: "cat /secrets/authToken"
				mode:    0o500
			}
			secret: "/secrets/authToken": repository.authToken
		}
	}

	// Computed JSON including repo URL and array of references
	out: {
		os.#File & {
			from: _ctr
			path: "/output.json"
		}
	}.contents & dagger.#Output
}

#Command: #"""
    # Collect repo's URL in HTTPS format
    # Version control agnostic command (Github/Gitlab)
    # protocol agnostic (SSH or HTTPS Base url)
    HTTPS='https://'
    URL=$(git -c user.name="$USER_NAME" -c user.email="$USER_EMAIL" ls-remote --get-url "$REMOTE" |
        sed 's/https:\/\///' | sed 's/git@//' | tr ':' '/' | head -n 1)

    # Collect references
    REFERENCES=$(jo -e -a $(git -c user.name="$USER_NAME" -c user.email="$USER_EMAIL" ls-remote "$REMOTE" "$REF" -q |
        cut -d$'\t' -f 2 | sed '/\^/d' | sed '/HEAD/d'))

    # Compute as JSON
    jo -p url="$HTTPS$URL" references=$REFERENCES > /output.json
    """#