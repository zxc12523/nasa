function convertImage(image) {
  const canvas = drawImageToCanvas(image);
  const ctx = canvas.getContext('2d');
  const set1 = new Set([3, 14, 17, 21, 25, 28, 33, 37, 41, 47, 51, 55, 60, 69, 72, 80, 84, 91, 98])

  let result = [];
  for (let y = 0; y < canvas.height; y++) {
    result.push([]);
    for (let x = 0; x < canvas.width; x++) {
      let data = ctx.getImageData(x, y, 1, 1).data;
      result[y].push(data[0]);
      result[y].push(data[1]);
      result[y].push(data[2]);
    }
  }
  const len = canvas.width - 1;

  for (let y = 0; y < canvas.height; y++) {
    for (let x = 0; x < canvas.width / 2; x = x + 3) {
      if (set1.has(x)) {
        let first = 3 * x, second = 3 * (len - x);
        if (result[y][first] != result[y][second]) {
          swappixel(ctx, x, y, result, second);
          swappixel(ctx, x + 1, y, result, second);
          swappixel(ctx, x + 2, y, result, second);
          swappixel(ctx, len - x, y, result, first);
          swappixel(ctx, len - x + 1, y, result, first);
          swappixel(ctx, len - x + 2, y, result, first);
        }
      }
    }
  }
  document.body.appendChild(canvas);
}

function swappixel(ctx, x, y, result, z) {
  var imageData = ctx.getImageData(x, y, 1, 1);
  var Data = imageData.data;
  console.log(x, y, z);
  console.log(result.length);
  Data[0] = result[y][z];
  Data[1] = result[y][z + 1];
  Data[2] = result[y][z + 2];
  ctx.putImageData(imageData, x, y);
}

function drawImageToCanvas(image) {
  const canvas = document.createElement('canvas');
  canvas.width = image.width;
  canvas.height = image.height;
  canvas.getContext('2d').drawImage(image, 0, 0, image.width, image.height);
  return canvas;
}

function convertArray(array) {
  return JSON.stringify(array).replace(/\[/g, '{').replace(/\]/g, '}');
}

function createParagraph() {
  var img1 = new Image(); // HTML5 Constructor
  img1.src = 'https://scontent-tpe1-1.xx.fbcdn.net/v/t1.15752-9/273217425_977229789601265_6816690687981595768_n.png?_nc_cat=108&ccb=1-5&_nc_sid=ae9488&_nc_ohc=cNBl_YWezKIAX-Vpp4w&_nc_ht=scontent-tpe1-1.xx&oh=03_AVLUTTKkE6r3zltvTnfDyXpgNusmopCuE8fUssIlf61_mw&oe=62412AD5';
  img1.crossOrigin = 'anonymous'
  convertImage(img1);
}

const buttons = document.querySelectorAll('button');

for (let i = 0; i < buttons.length; i++) {
  buttons[i].addEventListener('click', createParagraph);
}