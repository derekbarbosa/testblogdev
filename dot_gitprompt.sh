# ==============================================================================
#
#        STANDALONE POWERLINE-NAKED PROMPT (WITH DETAILED GIT INFO)
#
# ==============================================================================
#
# DISCLAIMER:
#
# PORTIONS OF THIS CODE WAS INSPIRED BY/CUT-PASTED FROM GIT-PROMPT.SH,
######### Copyright (C) 2006,2007 Shawn O. Pearce <spearce@spearce.org>
######### Distributed under the GNU General Public License, version 2.0.
#
# PORTIONS OF THIS CODE WERE ALSO INSPIRED BY THE OH-MY-BASH FRAMEWORK (OMB)
# WHICH IS LICENSED UNDER THE MIT LICENSE BY Robby Russell (2009-2017), Toan Nguyen (2017-present)
# AND THE RESPECTIVE CONTRIBUTORS.
######### https://raw.githubusercontent.com/ohmybash/oh-my-bash/refs/heads/master/LICENSE.md
#
# ------------------------------------------------------------------------------
# Part 1: Main Configuration -- Tweak your prompt's look and feel here!
# ------------------------------------------------------------------------------

# Define the order of segments on the prompt.
# CHANGED: Reordered to your preference.
PROMPT_SEGMENTS=(
  git
  python_venv
)

# --- Colors ---
C_RESET='\[\033[0m\]'
C_USER_INFO='\[\033[0;32m\]'         # Green
C_DIR='\[\033[0;34m\]'               # Blue
C_GIT_BRANCH='\[\033[0;36m\]'        # Cyan for the branch info
C_GIT_STASH='\[\033[38;5;208m\]'         # Orange for the stash count
C_GIT_STATUS='\[\033[0;33m\]'        # Yellow for status counts
C_PYTHON_VENV='\[\033[0;33m\]'       # Yellow
C_LAST_STATUS_ERROR='\[\033[0;31m\]' # Red

# --- Git Status Format & Icons ---
# CHANGED: New icons to match your desired format.
GIT_PROMPT_BRANCH_ICON=" "
GIT_PROMPT_AHEAD_ICON="↑"
GIT_PROMPT_BEHIND_ICON="↓"
GIT_PROMPT_DIVERGED_ICON="↕"
GIT_PROMPT_UNTRACKED_ICON="U:"
GIT_PROMPT_STAGED_ICON="S:"
GIT_PROMPT_MODIFIED_ICON="M:"

# --- Python Virtualenv ---
PYTHON_VENV_CHAR="🐍 "

# ------------------------------------------------------------------------------
# Part 2: Prompt Logic -- (Should not require editing)
# ------------------------------------------------------------------------------

# --- Segment: Python Virtual Environment ---
get_python_venv_segment() {
  local venv=""
  if [[ -n "$CONDA_DEFAULT_ENV" ]]; then venv="$CONDA_DEFAULT_ENV";
  elif [[ -n "$VIRTUAL_ENV" ]]; then venv=$(basename "$VIRTUAL_ENV"); fi
  if [[ -n "$venv" ]]; then echo -n "${C_PYTHON_VENV}${PYTHON_VENV_CHAR}${venv}${C_RESET}"; fi
}

# --- Segment: Git Repository Status (detailed) ---
get_git_segment() {
    local git_dir
    git_dir=$(git rev-parse --git-dir 2> /dev/null)
    [ -z "$git_dir" ] && return # Not a git repo

    local branch_name=$(git symbolic-ref --short HEAD 2>/dev/null) || \
                    branch_name=$(git rev-parse --short HEAD 2>/dev/null) || \
                    return # Not on a branch

	# Get just the remote's name (e.g., "origin")
    local remote_name=$(git config --get "branch.${branch_name}.remote" 2>/dev/null)

    local status_string=""

    # Get upstream tracking info
    local upstream_info=$(git rev-list --count --left-right "@{upstream}"...HEAD 2>/dev/null)
    if [[ -n "$upstream_info" ]]; then
        local behind ahead
        behind=$(echo "$upstream_info" | awk '{print $1}')
        ahead=$(echo "$upstream_info" | awk '{print $2}')

        if [[ "$behind" -gt 0 && "$ahead" -gt 0 ]]; then
            status_string+=" ${GIT_PROMPT_DIVERGED_ICON}${behind}${GIT_PROMPT_AHEAD_ICON}${ahead}"
        elif [[ "$ahead" -gt 0 ]]; then
            status_string+=" ${GIT_PROMPT_AHEAD_ICON}${ahead}"
        elif [[ "$behind" -gt 0 ]]; then
            status_string+=" ${GIT_PROMPT_BEHIND_ICON}${behind}"
        fi
    fi
	
    # Get file status counts
	local stash_count=$(git stash list 2>/dev/null | wc -l | tr -d ' ')
    local untracked_count=$(git ls-files --others --exclude-standard --directory --no-empty-directory | wc -l | tr -d ' ')
    local staged_count=$(git diff --name-only --cached | wc -l | tr -d ' ')
    local modified_count=$(git diff --name-only | wc -l | tr -d ' ')

    local file_status=""
    if [[ "$untracked_count" -gt 0 ]]; then file_status+=" ${GIT_PROMPT_UNTRACKED_ICON}${untracked_count}"; fi
    if [[ "$staged_count" -gt 0 ]]; then file_status+=" ${GIT_PROMPT_STAGED_ICON}${staged_count}"; fi
    if [[ "$modified_count" -gt 0 ]]; then file_status+=" ${GIT_PROMPT_MODIFIED_ICON}${modified_count}"; fi

    local final_git_string=""

    # Start with the branch icon
    final_git_string+="${C_RESET}${C_GIT_BRANCH}${GIT_PROMPT_BRANCH_ICON}"

    # Add remote name if it exists
    if [[ -n "$remote_name" ]]; then
		final_git_string+="(${remote_name}) "
    fi

    # Add local branch name
    final_git_string+="${branch_name}"

    # Add status info (ahead/behind, file counts)
    final_git_string+="${C_RESET}${C_GIT_STATUS}${status_string}${file_status}${C_RESET}"
	
	# Stash indicator
    if [[ "$stash_count" -gt 0 ]]; then
		final_git_string+="${C_GIT_STASH} @{${stash_count}}${C_RESET}"
    fi

	# Reset colors
	final_git_string+="${C_RESET}"

    echo -n "$final_git_string"
}

# --- Robust PS1 appender for complex BASE_PS1 (handles \[...\], OSC 133, etc.) ---

# Capture the user's original PS1 once
if [[ -z "${BASE_PS1+x}" ]]; then
  BASE_PS1="$PS1"
fi

build_prompt() {
  local last_status="$?"
  local extra_segments=""
  local separator=" "

  # python venv
  local python_output
  python_output=$(get_python_venv_segment)
  if [ -n "$python_output" ]; then
    extra_segments+="$separator$python_output"
  fi

  # git info (only if in repo)
  local in_git_repo=false
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    in_git_repo=true
    local git_output
    git_output=$(get_git_segment)
    if [ -n "$git_output" ]; then
      extra_segments+="$separator$git_output"
    fi
  fi

  # If not in git repo and nothing to append, restore original PS1 exactly
  if ! $in_git_repo && [ -z "$extra_segments" ]; then
    PS1="$BASE_PS1"
    return
  fi

  # --- Find the last escaped prompt symbol (e.g. '\$' or '\#') in BASE_PS1 ---
  # We use a bash regex with greedy .*, so it captures the last occurrence:
  #   prefix = everything before the final backslash+([$#])
  #   prompt_end_char = the $ or #
  #   suffix = remainder (often contains color resets / OSC sequences)
  local prefix=""
  local prompt_end_char=""
  local suffix=""

  if [[ "$BASE_PS1" =~ ^(.*)\\([#$])(.*)$ ]]; then
    prefix="${BASH_REMATCH[1]}"
    prompt_end_char="${BASH_REMATCH[2]}"
    suffix="${BASH_REMATCH[3]}"
  else
    # Fallback: no escaped \$ or \# found — try to find an unescaped $ or # (rare for your PS1)
    if [[ "$BASE_PS1" =~ ^(.*)([$#])(.*)$ ]]; then
      prefix="${BASH_REMATCH[1]}"
      prompt_end_char="${BASH_REMATCH[2]}"
      suffix="${BASH_REMATCH[3]}"
    else
      # No prompt symbol found — just append onto the base and return
      PS1="${BASE_PS1}${extra_segments:+${extra_segments} }"
      return
    fi
  fi

  # Trim any trailing spaces from prefix (keeps layout cleaner)
  prefix="${prefix%"${prefix##*[![:space:]]}"}${prefix##*}"  # noop-safe, keep prefix as-is

  # Rebuild PS1:
  # - place prefix first (original left-side prompt),
  # - then our appended segments,
  # - then a space + the escaped prompt character (e.g. '\$' ), and finally
  # - the original suffix (so any resets / OSC sequences remain in place)
  if [ -n "$extra_segments" ]; then
    PS1="${prefix}${extra_segments} \\${prompt_end_char}${suffix}"
  else
    # If extra_segments is empty but we're in git repo (edge case), still restore prefix + prompt char + suffix
    PS1="${prefix} \\${prompt_end_char}${suffix}"
  fi
}

# Attach build_prompt safely (avoid duplicate entries)
if [[ -n "$PROMPT_COMMAND" ]]; then
  case ";$PROMPT_COMMAND;" in
    *"; build_prompt;"*) : ;; # already present
    *) PROMPT_COMMAND="${PROMPT_COMMAND}; build_prompt" ;;
  esac
else
  PROMPT_COMMAND="build_prompt"
fi
