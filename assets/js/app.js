// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
import "flowbite/dist/flowbite.phoenix.js";
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"


let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

window.onload = () => {
    // event list: collapse and expand items
    eachSelected(".event-list-item", (el) => el.onclick = toggleItem);
    // event creation: add and remove items from the outcome list
    eachSelected(".form-list-remove-field", (el) => el.onclick = removeItem);
    eachSelected(".form-list-add-field", (el) => el.onclick = addItem);
    // event & resolution copy to clipboard
    eachSelected(".event-copy-to-clipboard", (el) => el.onclick = copyEventToClipboard(el.id));
    eachSelected(".resolution-copy-to-clipboard", (el) => el.onclick = copyResolutionToClipboard(el.id));

    // arbitrary copy to clipboard
    eachSelected(".data-copy-to-clipboard", (el) => el.onclick = copyTextToClipboard(el.getAttribute("data-any")));
}

const eachSelected = (selector, callback) => {
    Array.prototype.forEach.call(document.querySelectorAll(selector), callback);
};

// const toggleItem = (event) => {
//     let collapsible = event.target.
// }

const addItem = ({target: {dataset}}) => {
    let container = document.getElementById(dataset.container);
    let count = document.children.length;
    container.insertAdjacentHTML('beforeend', dataset.blueprint);
    let newItem = container.lastChild;
    newItem.lastChild.onclick = removeItem;
    newItem.firstChild.dataset.index = count;
    newItem.firstChild.id += `_${count}`;
    newItem.firstChild.focus();
}

const removeItem = (event) => {
    let index = event.target.dataset.index;
    let li = event.target.parentNode;
    let ol = li.parentNode;
    ol.removeChild(li);
    Array.prototype.forEach.call(ol.children   , (li, i) => {
        li.firstChild.dataset.index = i;
    });
}


const copyEventToClipboard = (eventId) => {
    let index = eventId.split("event-")[1];
    let targetId = "event-hex-" + index;
    let target = document.getElementById(targetId);
    copyToClipboard(target);
}

const copyResolutionToClipboard = (eventId) => {
    let index = eventId.split("resolution-")[1];
    let targetId = "resolution-hex-" + index;
    let target = document.getElementById(targetId);
    copyToClipboard(target);
}

const copyToClipboard = (data) => {
    data.select();
    // data.getSelectionRange(0, 99999);
    copyTextToClipboard(data.value);
    // TODO add alert copied to clipboard
}

const copyTextToClipboard = (text) => {
    navigator.clipboard.writeText(text);
}