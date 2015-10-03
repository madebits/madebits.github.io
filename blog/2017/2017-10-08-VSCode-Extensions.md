#Visual Studio Code Extensions

2017-10-08

<!--- tags: editor -->

An incomplete list of useful [VSCode extensions](https://marketplace.visualstudio.com/vscode).

##Look and Feel

* [Afterglow Theme](https://marketplace.visualstudio.com/items?itemName=gerane.Theme-Afterglow) - I am used to this theme from SublimeText and find it the most comfortable one to work, thought I switch up and now to other themes.

* [GitHub Clean White Theme](https://marketplace.visualstudio.com/items?itemName=saviorisdead.Theme-GitHubCleanWhite) - thought I use mostly Afterglow, sometimes a clear white theme is useful to keep around.

* [vscode-icons](https://marketplace.visualstudio.com/items?itemName=robertohuertasm.vscode-icons) - needs no introduction. While I try some other icon theme up and now, I find myself always coming back to this icon theme.

##Coding

* [Bookmarks](https://marketplace.visualstudio.com/items?itemName=alefragnani.Bookmarks) - I usually do not need bookmarks for my own code, but when moving around to a new codebase, bookmarks are very useful. It would be nice VSCode had some form of favorites management built in.

* [Bracket Pair Colorizer](https://marketplace.visualstudio.com/items?itemName=CoenraadS.bracket-pair-colorizer) - as name says, it helps figure quickly where your code brackets are.

* [Jumpy](https://marketplace.visualstudio.com/items?itemName=wmaurer.vscode-jumpy) - or the better one [MetaGo](https://marketplace.visualstudio.com/items?itemName=metaseed.metago) enables jumping around viewport text using keyboard.

##Git

* [Git Lens](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens) - I do not use Git via VSCode, but it is useful to see history of files within the VSCode.

##Useful

* [Code Spell Checker](https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker) - comming from SublimeText where spell check is build in, I find this extension indispensable, especially when I used VSCode as a text editor. It is not as good as SublimeText, but still usable. It would be nice VSCode had this support built in.


* [Markdown Preview Enhanced](https://marketplace.visualstudio.com/items?itemName=shd101wyy.markdown-preview-enhanced) - Ctrl+Shift+M and you have a much better preview for markdown documents that the [built in](https://code.visualstudio.com/docs/languages/markdown) one (which is also not bad).

##Optional

* [Output Colorizer](https://marketplace.visualstudio.com/items?itemName=IBM.output-colorizer) - colors Output window text. There is some value on this extension, thought most of time it gets colors wrong.

* [SVG Viewer](https://marketplace.visualstudio.com/items?itemName=cssho.vscode-svgviewer) - enabled preview of SVG files as images.

* [vscode-pdf](https://marketplace.visualstudio.com/items?itemName=tomoki1207.pdf) - enables preview of PDFs documents. I do not use it often, but still I know its there when I need it.

##Settings

VSCode is usable out of the box. Some customization is needed thought and here is a copy of my current settings. Some of these are added here because I switched them via menus, some are manually added.

```json
{
    "telemetry.enableTelemetry": false,
    "telemetry.enableCrashReporter": false,
    "editor.fontSize": 18,
    "editor.renderWhitespace": "boundary",
    "terminal.integrated.fontSize": 18,
    "markdown.preview.fontSize": 16,
    "workbench.startupEditor": "newUntitledFile",
    "workbench.iconTheme": "vscode-icons",
    "window.zoomLevel": 1,
    "editor.wordWrap": "on",
    "editor.fontFamily": "Fira Code",
    "editor.fontLigatures": false,
    "terminal.integrated.fontFamily": "'Droid Sans Mono', 'Courier New', monospace, 'Droid Sans Fallback'",
    "window.restoreWindows": "none",
    "workbench.colorCustomizations": {
        "statusBar.background" : "#353434",
        "statusBar.noFolderBackground" : "#212121",
        "statusBar.debuggingBackground": "#4B453D"
    },
    "workbench.colorTheme": "Afterglow",
    "workbench.activityBar.visible": true,
    "editor.rulers": [
        80,
        120
    ],
    "cSpell.enabledLanguageIds": [
        "c",
        "cpp",
        "csharp",
        "go",
        "handlebars",
        "html",
        "javascript",
        "javascriptreact",
        "json",
        "latex",
        "markdown",
        "php",
        "plaintext",
        "python",
        "restructuredtext",
        "text",
        "typescript",
        "typescriptreact",
        "yml"
    ]
}
```

##Hacks

Somehow `Find All References` does not work for JavaScript, which makes VSCode not really useful. It is not only [dynamic properties](https://github.com/Microsoft/vscode/issues/27246), even for classes in latest Node project latest VSCode does not find all references in all files. A workaround is to install [Find all references](https://marketplace.visualstudio.com/items?itemName=gayanhewa.referenceshelper) extension. This extension expects a copy of [rg](https://github.com/BurntSushi/ripgrep#installation) tool be available in path.

[Find all references](https://marketplace.visualstudio.com/items?itemName=gayanhewa.referenceshelper) explicitly has JavaScript excluded, given it is supposed VSCode can handle JavaScript better. To activate JavaScript, edit `~/.vscode/extensions/gayanhewa.referenceshelper-0.2.0/out/src/extension.js` and add `"javascript"` to its array of languages. After restart of VSCode, then `Find All References` menu will work. You have re-edit the file if you update this extension. I hope this is a temporary hack, until VSCode people decide to give JavaScript same attention they give to TypeScript.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2017/2017-10-13-Blocking-BlockAdBlock.md'>Blocking BlockAdBlock</a> <a rel='next' id='fnext' href='#blog/2017/2017-10-05-Clustering-Express-Node-Servers.md'>Clustering Express Node Servers</a></ins>
