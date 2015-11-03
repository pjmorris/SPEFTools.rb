
BEGIN { OFS=";"; }
{
if ($1 ~ /[a-f0-9][a-f0-9][a-f0-9]([a-f0-9])*/ && length($1) <= 7) { commit = $0 }
if ($1 ~ /^(-|[0-9]+$)/ && length($1) < 6) { print commit, $1, $2, $3 } 
if ($1 ~ /^$/) { }
}
