return {
    {
        -- NOTE:
        -- 1. We deliberately avoid using the higher-order abstractions
        -- provided by lazy.nvim, such as combining multiple `opts` functions
        -- to merge the options table that is eventually passed to the
        -- `xxx.setup` function, or using `keys` to define keybindings. The
        -- rationale behind this is to keep the configuration independent of
        -- any plugin manager's API, ensuring that migration to another package
        -- manager will be simpler. (If ever required in the future, though
        -- there are no current plans.)


        -- FIXME:
        -- 2. We are using our own fork instead of the original upstream
        -- (folke/snacks.nvim) because our PRs are still awaiting upstream
        -- approval. Until those are merged, we will continue using our fork. A
        -- GitHub Action is configured to perform a daily fast-forward merge
        -- with the upstream repository. This ensures that our fork remains
        -- consistently up to date.
        'milanglacier/snacks.nvim',
        branch = 'dev',
        init = function()
            -- Unlike `opts` (which lazy.nvim merges from multiple functions that
            -- can be defined repeatedly), lazy.nvim permits only a single `init`
            -- function per package. For this reason, we implemented our own
            -- `init_module` mechanism to perform multi-level setup during
            -- initialization.
            for _, module in pairs(Milanglacier.snacks.module) do
                module()
            end
        end,
        config = function()
            require('snacks').setup(Milanglacier.snacks.opts)
        end,
    },
}
