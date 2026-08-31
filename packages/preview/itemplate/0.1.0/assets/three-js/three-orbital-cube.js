
import * as THREE from 'three';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';

// init
const container = document.getElementById("three-orbital-cube");
let width = container.clientWidth;
let height = container.clientHeight;

const camera = new THREE.PerspectiveCamera(60, (1 * width) / (1 * height), 0.01, 10);
camera.position.z = 2;
camera.position.x = 0;
camera.position.y = 0;

const scene = new THREE.Scene();

const geometry = new THREE.BoxGeometry(1, 1, 1);
const material = new THREE.MeshNormalMaterial();

const mesh = new THREE.Mesh(geometry, material);
scene.add(mesh);

const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
renderer.setClearColor(0xf1f1f1, 0.5);
renderer.setSize(width, height);
renderer.setAnimationLoop( animate );
container.appendChild(renderer.domElement);

const controls = new OrbitControls(camera, renderer.domElement);
controls.enableDamping = true;

// handle resize

window.addEventListener("resize", onResize);

function onResize() {
  width = container.clientWidth;
  height = container.clientHeight;

  camera.aspect = width / height;
  camera.updateProjectionMatrix();

  renderer.setSize(width, height);
}

// animation

function animate( time ) {

	mesh.rotation.x = time / 20000;
	mesh.rotation.y = time / 10000;

	controls.update();

	renderer.render( scene, camera );

}
