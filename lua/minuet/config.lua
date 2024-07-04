local default_prompt = [[
You are the backend of an AI-powered code completion engine. Your task is to
provide code suggestions based on the user's input. The user' s code will be
enclosed in markers:

- `<beginCode>`: Start of the code context
- `<cursorPosition>`: Current cursor location
- `<endCode>`: End of the code context

]]

local default_guidelines = [[
Guidelines:
1. Offer completions after the `<cursorPosition>` marker.
2. Make sure you have maintained the user's existing whitespace and indentation. This is REALLY IMPORTANT!
3. Provide multiple completion options when possible.
4. Return completions in JSON format as a list of lists, with each inner list
representing a single completion option. Make sure it is a plain list without
keys.
5. The returned message will be further parsed and processed. Do not
   include additional comments or markdown code block fences. Return the json
   result directly.]]

local default_example = [[


Example input:
```
<beginCode>
# language: python
def fib(n):
    <cursorPosition>

fib(5)
<endCode>
```

Example output:
```
[
[
"    '''",
"    Recursive Fibonacci implementation",
"    '''",
"    if n < 2:",
"        return n",
"    return fib(n - 1) + fib(n - 2)"
],
[
"    '''",
"    Iterative Fibonacci implementation",
"    '''",
"    a, b = 0, 1",
"    for _ in range(n):",
"        a, b = b, a + b",
"    return a"
]
]
```
]]

local claude_guidelines =
    string.format('%s\n%s', default_guidelines, '6. Keep each completion option concise, limiting it to several lines.')

local M = {
    provider = 'codestral',
    context_window = 12800, -- the maximum total characters of the context before and after cursor
    context_ratio = 0.6,
    -- when the total characters exceed the context window, the ratio of
    -- context before cursor and after cursor, the larger the ratio the more
    -- context before cursor will be used.
    throttle = 1000, -- only send the request every x milliseconds, use 0 to disable throttle.
    notify = true, -- show notification when request is sent
    request_timeout = 3, -- the timeout of the request in seconds
    -- if completion item has multiple lines, create another completion item only containing its first line.
    add_single_line_entry = true,
    provider_options = {
        codestral = {
            model = 'codestral-latest',
            max_tokens = 128,
            -- the number of completions request to send. Note that when
            -- add_single_line_entry is true, there can be more items returned.
            n_completions = 1,
            stop = { '\n\n' }, -- the identifier to stop the completion generation
        },
        openai = {
            model = 'gpt-4o',
            system = default_prompt .. default_guidelines .. default_example,
        },
        claude = {
            max_tokens = 512,
            model = 'claude-3-5-sonnet-20240620',
            system = default_prompt .. claude_guidelines .. default_example,
            stop = nil,
        },
    },
}

return M
