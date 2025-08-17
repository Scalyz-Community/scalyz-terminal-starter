# Truecolor brand
typeset -g SCALYZ_BRAND="#407EC9"
typeset -g SCALYZ_DIM="#9bbde5"

# Fallback if terminal lacks truecolor
if [[ -z "$COLORTERM" || "$COLORTERM" != *(truecolor|24bit)* ]]; then
  SCALYZ_BRAND="blue"
  SCALYZ_DIM="cyan"
fi

# Git summary
scalyz_git_prompt() {
  local branch dirty
  branch=$(git symbolic-ref --short -q HEAD 2>/dev/null) || return
  git diff --quiet --ignore-submodules HEAD &>/dev/null; [[ $? -ne 0 ]] && dirty="*"
  echo "%F{$SCALYZ_DIM} ${branch}${dirty}%f"
}

# Python venv
scalyz_venv_prompt() { [[ -n "$VIRTUAL_ENV" ]] && echo "%F{$SCALYZ_DIM}($(basename "$VIRTUAL_ENV"))%f" }

# Kubernetes context
scalyz_kube_prompt() {
  command -v kubectl &>/dev/null || return
  local ctx ns
  ctx=$(kubectl config current-context 2>/dev/null) || return
  ns=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)
  [[ -n "$ctx" ]] && echo "%F{$SCALYZ_DIM}⎈ ${ctx}${ns:+:${ns}}%f"
}

# SSH indicator
scalyz_ssh_prompt() { [[ -n "$SSH_CONNECTION" ]] && echo "%F{$SCALYZ_DIM}ssh%f" }

# AWS profile
scalyz_aws_prompt() { [[ -n $AWS_PROFILE ]] && echo "%F{white}[%F{$SCALYZ_BRAND}$AWS_PROFILE%F{white}]%f" }

# PROD warning
scalyz_warn_prod() {
  local prod_regex='(prod|live|main)'
  if [[ $AWS_PROFILE =~ $prod_regex ]] || (command -v kubectl >/dev/null 2>&1 && kubectl config current-context 2>/dev/null | grep -Eq "$prod_regex"); then
    echo "%F{red}⚠ PROD%f"
  fi
}

# Exit code if non-zero
scalyz_status() { [[ $RETVAL -ne 0 ]] && echo "%F{red}✖ $RETVAL%f" }

precmd() { RETVAL=$? }

# Prompt
PROMPT='%F{'$SCALYZ_BRAND'}scalyz.com%f  %F{'$SCALYZ_DIM'}%n@%m%f %F{white}%~%f $(scalyz_git_prompt) $(scalyz_venv_prompt) $(scalyz_kube_prompt) $(scalyz_ssh_prompt) $(scalyz_aws_prompt) $(scalyz_warn_prod)
%F{'$SCALYZ_BRAND'}❯%f '

RPROMPT='%F{'$SCALYZ_DIM'}%*%f $(scalyz_status)'