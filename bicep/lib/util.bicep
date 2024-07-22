@export()
func replaceMultiple(input string, replacements { *: string }) string => reduce(
  items(replacements), input, (cur, next) => replace(string(cur), next.key, next.value))

@export()
func generatePassword(guid string, nr1 int, nr2 int, nr3 int, nr4 int, nr5 int, chars string[], numbers int[], alphaUpper string[]) string => '${chars[nr1]}${chars[nr2]}${chars[nr3]}${guid}${numbers[nr1]}${numbers[nr2]}${alphaUpper[nr5]}${alphaUpper[nr4]}'
