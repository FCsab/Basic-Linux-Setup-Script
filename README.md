<h1>My basic setup for Linux.</h1>
<br>
<h2>This will install the following packages:</h2>
    <ul>
        <li>Media codecs</li>
        <li>Steam</li>
        <li>Discord</li>
        <li>Grub-Customizer</li>
        <li>Proton-GE 9-11</li>
        <li>Gimp</li>
        <li>Fish (doesnt change the shell)</li>
        <li>VS code</li>
        <li>Rust</li>
        <li>Libre Office</li>
        <li>Obsidian</li>
        <li>Modrinth (minecraft modloader)</li>
        <li>Retro Arch</li>
        <li>KeePassXC</li>
        <li>Transmission</li>
        <li>Shotcut</li>
        <li>Neofetch</li>
        <li>OpenRGB</li>
        <li>Mangohud</li>
    </ul>

<h2>Requirements</h2>
<br>
<ul>
    <li>sudo permission</li>
    <li>wget</li>
</ul>

<br>

<h2>Supported systems:</h2>
<ul>
    <li>Fedora and Debian are currently supported, Arch support coming later.</li>
</ul>

<br>

<h2>On Debian there are false positives when writing out failed installations. Restart your system after install, they should appear.</h2>

<h2>Usage:</h2>
<h3>Download setup.sh</h3>

```bash
wget https://raw.githubusercontent.com/FCsab/Basic-Linux-Setup-Script/main/setup.sh
```

<h3>Make file executeable</h3>

```bash
chmod +x setup.sh
```

<h3>Run the file as sudo</h3>

```bash
sudo bash setup.sh
```