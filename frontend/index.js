import { backend } from 'declarations/backend';

const imageUpload = document.getElementById('imageUpload');
const processButton = document.getElementById('processButton');
const spinner = document.getElementById('spinner');
const originalImage = document.getElementById('originalImage');
const processedImage = document.getElementById('processedImage');

let imageFile = null;

imageUpload.addEventListener('change', (event) => {
    imageFile = event.target.files[0];
    if (imageFile) {
        const reader = new FileReader();
        reader.onload = (e) => {
            originalImage.src = e.target.result;
        };
        reader.readAsDataURL(imageFile);
    }
});

processButton.addEventListener('click', async () => {
    if (!imageFile) {
        alert('Please upload an image first.');
        return;
    }

    spinner.classList.remove('d-none');
    processButton.disabled = true;

    try {
        const imageData = await readFileAsUint8Array(imageFile);
        const result = await backend.processImage(imageData);
        handleProcessedResult(result);
    } catch (error) {
        console.error('Error processing image:', error);
        alert('An error occurred while processing the image.');
    } finally {
        spinner.classList.add('d-none');
        processButton.disabled = false;
    }
});

async function readFileAsUint8Array(file) {
    return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = (event) => {
            resolve(new Uint8Array(event.target.result));
        };
        reader.onerror = (error) => reject(error);
        reader.readAsArrayBuffer(file);
    });
}

function handleProcessedResult(result) {
    if (result.ok) {
        // Display the result text
        const resultContainer = document.createElement('div');
        resultContainer.textContent = result.ok;
        document.body.appendChild(resultContainer);
    } else {
        // Display the error message
        alert(`Error: ${result.err}`);
    }
}
