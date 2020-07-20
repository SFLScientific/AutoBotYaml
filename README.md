## sets QA group in autobot yaml file

has parameters for
- organization
    - Name of the organization
    - ORG=""
- QA team and fallback QA team
    - name of the project QA team and a fallback QA team
    - TEAM=""
    - FALLBACK_TEAM="QA"
-  project manager team
    - Name of project manager team that will be xor'd from QA team
    - PM_TEAM="ProjectManagers"
- yml file
   - YAML_FILE="bot.yml"

To set the github token used
change this C code
```C
#include <stdio.h>
int main() {
   printf("tokenGoesHere\n");
   return 0;
}
```
and compile it to `print_token` with `gcc -o print_token print_token.c`
