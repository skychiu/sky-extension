https://poe.com/s/pV7gQ6EM1H1lXDDqP2a4

# Complete Guide: Force-Installing an Unpacked Chrome Extension on Mac

This guide shows you how to force-install your unpacked Chrome extension across all user accounts on a Mac, preventing users from disabling it, and ensuring it works in regular mode, incognito mode, and guest mode.

## Step 1: Pack Your Extension

### Get Your Extension ID First (Important!)

Before packing, you need to note your extension ID from the unpacked version:

1. Open `chrome://extensions`
2. Enable "Developer mode"
3. Find your unpacked extension and copy its ID (it looks like: `abcdefghijklmnopqrstuvwxyzabcdef`)

**Important:** Keep the same extension ID by using the same private key for all future updates.

### Pack the Extension

#### Option A: Using Chrome UI
1. Open `chrome://extensions`
2. Enable "Developer mode"
3. Click "Pack extension"
4. Select your unpacked extension's root directory
5. Leave "Private key file" empty for first-time packing
6. Chrome generates:
   - `extension.crx` (the packed extension)
   - `extension.pem` (private key - **save this for future updates!**)

#### Option B: Using Command Line
```bash
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --pack-extension=/path/to/your/unpacked/extension
```

This creates `extension.crx` and `extension.pem` in the parent directory of your extension.

### Verify the Extension ID

After packing, temporarily install the CRX to verify the extension ID matches:

1. Drag `extension.crx` into `chrome://extensions`
2. Verify the ID matches what you noted earlier
3. Remove the test installation

## Step 2: Set Up Local Hosting Directory

Create a directory to host your extension files:

```bash
sudo mkdir -p "/Library/Application Support/ChromeExtensions"
```

Copy your packed extension:

```bash
sudo cp /path/to/extension.crx "/Library/Application Support/ChromeExtensions/"
```

Set proper permissions:

```bash
sudo chmod 644 "/Library/Application Support/ChromeExtensions/extension.crx"
```

## Step 3: Create Update Manifest

Create the update manifest file:

```bash
sudo nano "/Library/Application Support/ChromeExtensions/update.xml"
```

Add this content (replace `YOUR_EXTENSION_ID` with your actual extension ID, and set the correct version number from your `manifest.json`):

```xml
<?xml version='1.0' encoding='UTF-8'?>
<gupdate xmlns='http://www.google.com/update2/response' protocol='2.0'>
  <app appid='YOUR_EXTENSION_ID'>
    <updatecheck codebase='file:///Library/Application%20Support/ChromeExtensions/extension.crx' version='1.0.0' />
  </app>
</gupdate>
```

**Note:** The version here should match the version in your extension's `manifest.json`.

Set permissions:

```bash
sudo chmod 644 "/Library/Application Support/ChromeExtensions/update.xml"
```

## Step 4: Create Chrome Management Policy

Create the managed preferences directory:

```bash
sudo mkdir -p "/Library/Managed Preferences"
```

Create the Chrome policy file:

```bash
sudo nano "/Library/Managed Preferences/com.google.Chrome.plist"
```

Add this content (replace `YOUR_EXTENSION_ID` with your actual extension ID):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>ExtensionInstallForcelist</key>
    <array>
        <string>YOUR_EXTENSION_ID;file:///Library/Application%20Support/ChromeExtensions/update.xml</string>
    </array>
    <key>ExtensionSettings</key>
    <dict>
        <key>YOUR_EXTENSION_ID</key>
        <dict>
            <key>installation_mode</key>
            <string>force_installed</string>
            <key>update_url</key>
            <string>file:///Library/Application%20Support/ChromeExtensions/update.xml</string>
            <key>allowed_in_incognito</key>
            <true/>
        </dict>
    </dict>
</dict>
</plist>
```

Set proper permissions:

```bash
sudo chmod 644 "/Library/Managed Preferences/com.google.Chrome.plist"
sudo chown root:wheel "/Library/Managed Preferences/com.google.Chrome.plist"
```

## Step 5: Apply Changes

Restart Chrome completely (all windows and processes):

```bash
killall "Google Chrome"
```

When users relaunch Chrome, the extension will be automatically installed and cannot be disabled or removed.

## Final Directory Structure

Your setup should look like this:

```
/Library/Application Support/ChromeExtensions/
├── extension.crx
└── update.xml

/Library/Managed Preferences/
└── com.google.Chrome.plist
```

## Verification

Users can verify the installation:

1. **Regular Mode:** Open `chrome://extensions` - Your extension should appear with "Managed" label and no disable/remove options
2. **Incognito Mode:** Open an incognito window (Cmd+Shift+N), go to `chrome://extensions` - Your extension should be active and show "Allowed in Incognito"
3. **Policy Check:** Open `chrome://policy` - Should show `ExtensionInstallForcelist` and `ExtensionSettings` policies with `allowed_in_incognito: true`

## Updating Your Extension

When you need to update the extension:

### 1. Pack the Updated Extension

**Critical:** Use the same `extension.pem` file to maintain the same extension ID:

```bash
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --pack-extension=/path/to/updated/extension --pack-extension-key=/path/to/extension.pem
```

### 2. Replace the CRX File

```bash
sudo cp /path/to/extension.crx "/Library/Application Support/ChromeExtensions/"
```

### 3. Update the Version in update.xml

Edit the update manifest:

```bash
sudo nano "/Library/Application Support/ChromeExtensions/update.xml"
```

Update the version number (e.g., from `1.0.0` to `1.0.1`):

```xml
<?xml version='1.0' encoding='UTF-8'?>
<gupdate xmlns='http://www.google.com/update2/response' protocol='2.0'>
  <app appid='YOUR_EXTENSION_ID'>
    <updatecheck codebase='file:///Library/Application%20Support/ChromeExtensions/extension.crx' version='1.0.1' />
  </app>
</gupdate>
```

### 4. Chrome Will Auto-Update

Chrome checks for updates periodically. Users will automatically get the new version within a few hours. To force immediate update for testing:

1. Open `chrome://extensions`
2. Click "Update" button at the top

## Features of This Setup

✅ **Auto-installs** for all users and all Chrome profiles  
✅ **Prevents removal** - users cannot disable or uninstall  
✅ **Works for new profiles** - automatically applies to newly created profiles  
✅ **Applies to guest mode** - guest sessions also get the extension  
✅ **Works in incognito mode** - extension is enabled in incognito windows  
✅ **Survives Chrome updates** - policies persist through Chrome updates  
✅ **Easy updates** - just replace CRX and update version number

## Troubleshooting

**Extension not appearing:**
- Verify the extension ID is correct in all files
- Check that Chrome is completely closed before relaunching
- Check `chrome://policy` to see if policies are loaded
- Verify file permissions are correct (644 for files)

**Extension appears but doesn't work:**
- Check the version number in `update.xml` matches your `manifest.json`
- Verify the CRX file is not corrupted
- Check Chrome's console for errors at `chrome://extensions`

**Extension not working in incognito:**
- Verify `allowed_in_incognito` is set to `<true/>` in the plist file
- Check `chrome://policy` in an incognito window to confirm the policy is applied
- Some extension features may require additional permissions in the manifest

**Updates not working:**
- Ensure you used the same `extension.pem` file when repacking
- Verify the version number in `update.xml` is higher than the current version
- Check file permissions after replacing files

**Guest mode issues:**
- Guest mode should work automatically with force-installed extensions
- Verify in a guest session by opening `chrome://extensions`

## Security Notes

- Keep your `extension.pem` file secure and backed up - without it, you cannot update the extension with the same ID
- The CRX file in `/Library/Application Support/ChromeExtensions/` should only be writable by root
- Users cannot bypass these policies without admin access to remove the plist file
