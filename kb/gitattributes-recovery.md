# Recovering after .gitattributes corrupted binaries

If `* text eol=lf` was in `.gitattributes` and you staged (or committed) binaries, Git applied line-ending conversion and corrupted them. You have not committed yet, so the corruption is only in the **index** (staging) and possibly in the **working tree** if Git ever wrote converted bytes to disk.

## 1. Unstage everything

Stops the corrupted content in the index from being committed. Working tree is unchanged.

```bash
cd /path/to/facts
git restore --staged .
```

Or: `git reset HEAD`

## 2. Restore corrupted files from the last good commit

You said you have not committed since the .gitattributes change, so **HEAD** should still have good binaries. Replace broken files in the working tree with the version from HEAD:

```bash
# Restore all known binary types from HEAD (adjust paths if your repo layout differs)
git checkout HEAD -- '*.png' '*.jpg' '*.jpeg' '*.pdf' '*.gif' '*.webp' '*.zip' '*.tif' '*.tiff'
```

If you need to restore **everything** except `.gitattributes` (so you keep the fixed attributes):

```bash
git checkout HEAD -- .
git checkout -- .gitattributes   # re-apply the fixed .gitattributes (only *.md *.txt are text)
```

(Re-run the second line only if the first overwrote .gitattributes; the fixed .gitattributes should have only `*.md text eol=lf` and `*.txt text eol=lf`.)

## 3. Files that were never committed in a good state

Script-generated files (e.g. `Datasets/imageset_preview-*.png`) may never have been in a good state in Git. For those, **re-run the script** to regenerate:

```bash
# Example: regenerate one imageset preview (run from polisher, path to imageset folder and output PNG in facts repo)
polisher/.venv/bin/python polisher/facts/render_imageset_map_preview.py /mnt/d/imagesets/bond_ave/2026-02-16-orbit /path/to/facts/Datasets/imageset_preview-bond_ave-2026-02-16-orbit.png
```

Repeat for each imageset preview PNG (and any other generated binaries).

## 4. If HEAD is already bad

If you had already committed with the bad .gitattributes, HEAD's blobs are corrupted. Find the last good commit (before the .gitattributes change) and restore from it:

```bash
git log -1 -p -- .gitattributes   # find the commit that added * text eol=lf
git checkout <commit-before-that>^ -- '*.png' '*.jpg' ...   # restore binaries from that commit
```

Then fix `.gitattributes` again (only `*.md` and `*.txt` as text) and commit.

## 5. Going forward

`.gitattributes` should only list text types, e.g.:

```
*.md text eol=lf
*.txt text eol=lf
```

All other files (including every binary) are left untouched by Git's line-ending logic.
