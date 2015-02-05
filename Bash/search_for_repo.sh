function search_parents_for_dotgit {
  curpath=$(pwd)
  found_dotgit=0
  while [ "$curpath" != "/" ] ; do
    if [ -e "$curpath/.git" ] ; then
      found_dotgit=1
      export last_git_path="$curpath/.git"
      break
    fi
    curpath=$(dirname "$curpath")
  done
  return $found_dotgit
}

function parse_git_branch {
  if ! search_parents_for_dotgit ; then
    output=$(git branch --no-color 2>/dev/null)
    errstate=$?
    if [ $errstate -eq 0 ] ; then
      output2=$(echo "$output" | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
      echo \ \(git:$output2\)
    fi
  fi
}

function parse_just_git_branch {
  if ! search_parents_for_dotgit ; then
    output=$(git branch --no-color 2>/dev/null)
    errstate=$?
    if [ $errstate -eq 0 ] ; then
      output2=$(echo "$output" | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
      echo $output2
    fi
  fi
}

function parse_hg_branch_orig {
  output=$(hg branch 2> /dev/null)
  errstate=$?
  if [ $errstate -eq 0 ] ; then
     echo \ \(hg:$output\)
  fi
}

function search_parents_for_dothg {
  curpath=$(pwd)
  found_dothg=0
  while [ "$curpath" != "/" ] ; do
    if [ -e "$curpath/.hg" ] ; then
      found_dothg=1
      export last_hg_path="$curpath/.hg"
      break
    fi
    curpath=$(dirname "$curpath")
  done
  return $found_dothg
}

function parse_hg_branch_prepass {
  if ! search_parents_for_dothg ; then
     parse_hg_branch_orig
  fi
}

# avoids invoking python
# FIXME: this is broken because it assumes the file <hgpath>/branch exists,
# which is often true for my repo's but certainly not true in general.
function parse_hg_branch {
  if ! search_parents_for_dothg ; then
    if [ -e "$last_hg_path/branch" ] && [ -s "$last_hg_path/patches/status" ] ; then
      echo \ \(hg:$(cat "$last_hg_path/branch")\,$(tail -1 "$last_hg_path/patches/status" | sed -e 's/.*://')\)
    else if [ -e "$last_hg_path/branch" ] ; then
      echo \ \(hg:$(cat "$last_hg_path/branch")\)
    else if [ -s "$last_hg_path/patches/status" ] ; then
      echo \ \($(tail -1 "$last_hg_path/patches/status" | sed -e 's/.*://')\)
    fi
    fi
    fi
  fi
}

