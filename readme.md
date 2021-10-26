<style>
    table, td, th, tr {
        border: none;
        padding: 2px;
    }
    th {
        font-weight: bold;
    }
</style>
# Valapkg
A dependency manager and build system for Vala projects.

## Getting started
### Installation
<table>
    <tr>
        <th>Prebuilt</th>
        <th>Build from Source</th>
    </tr>
    <tr>
        <a href="https://snapcraft.io/valapkg">
  <img alt="Get it from the Snap Store" src="https://snapcraft.io/static/images/badges/en/snap-store-white.svg" />
</a>
    </tr>
    <tr>
        <h4>Dependencies</h4>
        <ul>
            <li>Vala</li>
            <li>Meson</li>
            <li>glib2</li>
            <li>libsoup 2.4</li>
            <li>json-glib 1.0</li>
            <li>libgee 0.8</li>
            <li>glib-networking</li>
        </ul>
        <h4>Build</h4>
        <pre><code>
meson builddir
ninja -C builddir
sudo ninja -C builddir install
</code></pre>
    </tr>
</table>