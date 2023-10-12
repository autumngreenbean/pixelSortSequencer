/*
This code accesses a target folder which contains an image sequence.
 Begin by creating a folder which has an image sequence in it.
 */

//Mouseclick progresses the image sequence animations
//you MUST modify parameters indicated by '@'

/*****
 ASDF Pixel Sort by Kim Asendorf 2010 kimasendorf.com
 
/*Sorting modes
 0 = white
 1 = black
 2 = bright
 3 = dark
 */

//a) folder navigation
int size;
int frame;
PImage[] images;
PGraphics canvas;

//b) animation: ASDF pixel-sort
int mode = 2;
PImage img;
String fileType = "png";
int loops = 10000;

/*** adjust these parameters
int whiteValue = color(240); // Sort pixels brighter than this value
int blackValue = color(15); // Sort pixels darker than this value
int brightValue = 100; // Sort pixels with brightness greater than this value
int darkValue = 30; // Sort pixels with brightness less than this value

/*** */

int whiteValue;
int blackValue;
int brightValue;
int darkValue;

int row = 0;
int column = 0;
boolean saved = false;

void setup() {
  size(640, 480);
  frame = 50;
  canvas = createGraphics(1080, 1080);

  /***file navigation*/
  File folder = new File("/Users/jinggreen/Desktop/sorted"); // Create 'folder' from the target folder's file path
  File[] listOfFiles = folder.listFiles(); // Create an array from items in 'folder'
  java.util.Arrays.sort(listOfFiles);  // Sort 'folder' items by name

  int validImageCount = 0; // Initialize a count for valid image files
  size = listOfFiles.length; // Set the size to the total number of files in the folder
  images = new PImage[size]; // Create an array to store images

  for (int i = 0; i < size; i++) {
    File file = listOfFiles[i];
    String fileName = file.getName().toLowerCase();

    // Check if the file is an image with a supported extension
    if (fileName.endsWith(".jpg") || fileName.endsWith(".jpeg") || fileName.endsWith(".png") || fileName.endsWith(".gif") || fileName.endsWith(".bmp")) {
      images[validImageCount] = loadImage(file.getAbsolutePath()); // Use getAbsolutePath() to load images with the full path
      validImageCount++;
    }
  }

  size = validImageCount; // Set the size to the count of valid image files
  println("File size: " + size); // Verify file size matches the number of valid image files
  println("Array size: " + images.length);
  println("Array item 1: " + images[0]);

  /***animation*/
  img = images[frame]; //need to cycle thru this important value
  size(1, 1);
  surface.setResizable(true);
  surface.setSize(img.width, img.height);
  image(img, 0, 0, width, height);
}

void draw() {
  img = images[frame];

  whiteValue = calculateWhiteThreshold(img, 5); // Calculate the threshold as 5% of max brightness
  blackValue = calculateBlackThreshold(img, 5); // Calculate the threshold as 5% of min brightness
  brightValue = calculateBrightThreshold(img, 5); // Calculate the threshold as 5% of average brightness
  darkValue = calculateDarkThreshold(img, 5); // Calculate the threshold as 5% of average brightness

    
  if (frameCount <= loops) {
    // Load the current frame's pixels
    img.loadPixels();
    
    // Calculate threshold values based on the current frame
    
    
    // Loop through columns
    while (column < img.width - 1) {
      img.loadPixels();
      sortColumn(whiteValue, blackValue, brightValue, darkValue);
      column++;
      img.updatePixels();
    }

    // Loop through rows
    while (row < img.height - 1) {
      img.loadPixels();
      sortRow(whiteValue, blackValue, brightValue, darkValue);
      row++;
      img.updatePixels();
    }
  }

  // load updated image onto surface and scale to fit the display width and height
  image(img, 0, 0, img.width, img.height);
 if (mousePressed) img.save(frameCount + "_" + mode + ".png"); //uncomment to save images on mousePressed

  //if (!saved && frameCount >= loops) {
  //  // save img
  //  img.save(imgFileName + "_" + mode + ".png");

  //  saved = true;
  //  println("Saved frame " + frameCount);

  //  // exiting here can interrupt file save, wait for user to trigger exit
  //  println("Click or press any key to exit...");
  //}
  
}

int calculateWhiteThreshold(PImage img, float percentage) {
  int maxBrightness = 0;
  for (int i = 0; i < img.pixels.length; i++) {
    int brightnessValue = int(brightness(img.pixels[i])); // Cast to int
    if (brightnessValue > maxBrightness) {
      maxBrightness = brightnessValue;
    }
  }
  return int(maxBrightness * (percentage / 100.0)); // Calculate the threshold as a percentage of max brightness
}

int calculateBlackThreshold(PImage img, float percentage) {
  int minBrightness = 255;
  for (int i = 0; i < img.pixels.length; i++) {
    int brightnessValue = int(brightness(img.pixels[i])); // Cast to int
    if (brightnessValue < minBrightness) {
      minBrightness = brightnessValue;
    }
  }
  return int(minBrightness * (percentage / 100.0)); // Calculate the threshold as a percentage of min brightness
}

int calculateBrightThreshold(PImage img, float percentage) {
  int avgBrightness = 0;
  for (int i = 0; i < img.pixels.length; i++) {
    avgBrightness += int(brightness(img.pixels[i])); // Cast to int
  }
  avgBrightness /= img.pixels.length;
  return int(avgBrightness * (percentage / 100.0)); // Calculate the threshold as a percentage of average brightness
}

int calculateDarkThreshold(PImage img, float percentage) {
  int avgBrightness = 0;
  for (int i = 0; i < img.pixels.length; i++) {
    avgBrightness += int(brightness(img.pixels[i])); // Cast to int
  }
  avgBrightness /= img.pixels.length;
  return int(avgBrightness * (percentage / 100.0)); // Calculate the threshold as a percentage of average brightness
}



void mousePressed() {
  if (frame < images.length - 1) {
    frame++;
    if (frame > images.length-1) frame = 0;
    img = images[frame];
    
    // Recalculate thresholds for the new frame
    whiteValue = calculateWhiteThreshold(img,1);
    blackValue = calculateBlackThreshold(img,1);
    brightValue = calculateBrightThreshold(img,1);
    darkValue = calculateDarkThreshold(img,1);
    
    // Reset row and column to start sorting from the beginning
    row = 0;
    column = 0;
  }
println("whiteValue: " + whiteValue + " " + "blackValue: " + blackValue + " " +
      "brightValue: " + brightValue + " " + "darkValue: " + darkValue + " ");
      
}

void normalizeImage(PImage img) {
  img.loadPixels();

  // Define variables to keep track of min and max brightness values for each channel
  float minR = 255, minG = 255, minB = 255;
  float maxR = 0, maxG = 0, maxB = 0;

  // Find the minimum and maximum brightness values for each channel
  for (int i = 0; i < img.pixels.length; i++) {
    float r = red(img.pixels[i]);
    float g = green(img.pixels[i]);
    float b = blue(img.pixels[i]);
    
    if (r < minR) minR = r;
    if (r > maxR) maxR = r;
    if (g < minG) minG = g;
    if (g > maxG) maxG = g;
    if (b < minB) minB = b;
    if (b > maxB) maxB = b;
  }

  // Normalize the image by adjusting each channel separately
  for (int i = 0; i < img.pixels.length; i++) {
    float r = red(img.pixels[i]);
    float g = green(img.pixels[i]);
    float b = blue(img.pixels[i]);
    
    r = map(r, minR, maxR, 0, 255);
    g = map(g, minG, maxG, 0, 255);
    b = map(b, minB, maxB, 0, 255);

    img.pixels[i] = color(r, g, b);
  }

  img.updatePixels();
}


void sortRow(int whiteValue, int blackValue, int brightValue, int darkValue) {
  // current row
  int y = row;

  for (int x = 0; x < img.width; x++) {
    int currentPixel = img.pixels[x + y * img.width];

    switch (mode) {
    case 0:
      if (brightness(currentPixel) > brightness(whiteValue)) {
        int nextX = getNextWhiteX(x, y);
        if (nextX > x) {
          sortPixels(x, nextX, y);
          x = nextX;
        }
      }
      break;
    case 1:
      if (brightness(currentPixel) < brightness(blackValue)) {
        int nextX = getNextBlackX(x, y);
        if (nextX > x) {
          sortPixels(x, nextX, y);
          x = nextX;
        }
      }
      break;
    case 2:
      if (brightness(currentPixel) > brightValue) {
        int nextX = getNextBrightX(x, y);
        if (nextX > x) {
          sortPixels(x, nextX, y);
          x = nextX;
        }
      }
      break;
    case 3:
      if (brightness(currentPixel) < darkValue) {
        int nextX = getNextDarkX(x, y);
        if (nextX > x) {
          sortPixels(x, nextX, y);
          x = nextX;
        }
      }
      break;
    default:
      break;
    }
  }
}

void sortColumn(int whiteValue, int blackValue, int brightValue, int darkValue) {
  // current column
  int x = column;

  for (int y = 0; y < img.height; y++) {
    int currentPixel = img.pixels[x + y * img.width];

    switch (mode) {
    case 0:
      if (brightness(currentPixel) > brightness(whiteValue)) {
        int nextY = getNextWhiteY(x, y);
        if (nextY > y) {
          sortPixels(y, nextY, x);
          y = nextY;
        }
      }
      break;
    case 1:
      if (brightness(currentPixel) < brightness(blackValue)) {
        int nextY = getNextBlackY(x, y);
        if (nextY > y) {
          sortPixels(y, nextY, x);
          y = nextY;
        }
      }
      break;
    case 2:
      if (brightness(currentPixel) > brightValue) {
        int nextY = getNextBrightY(x, y);
        if (nextY > y) {
          sortPixels(y, nextY, x);
          y = nextY;
        }
      }
      break;
    case 3:
      if (brightness(currentPixel) < darkValue) {
        int nextY = getNextDarkY(x, y);
        if (nextY > y) {
          sortPixels(y, nextY, x);
          y = nextY;
        }
      }
      break;
    default:
      break;
    }
  }
}

void sortPixels(int start, int end, int constant) {
  color[] sorted = new color[end - start];

  // Ensure the start and end indices are within the image bounds
  start = constrain(start, 0, img.width * img.height - 1);
  end = constrain(end, 0, img.width * img.height);

  for (int i = 0; i < end - start; i++) {
    int index = start + i * img.width + constant;
    // Ensure the index is within bounds
    index = constrain(index, 0, img.pixels.length - 1);
    sorted[i] = img.pixels[index];
  }

  sorted = sort(sorted);

  for (int i = 0; i < end - start; i++) {
    int index = start + i * img.width + constant;
    // Ensure the index is within bounds
    index = constrain(index, 0, img.pixels.length - 1);
    img.pixels[index] = sorted[i];
  }
}




// white x
int getFirstNoneWhiteX(int x, int y) {
  while (img.pixels[x + y * img.width] < whiteValue) {
    x++;
    if (x >= img.width) return -1;
  }
  return x;
}

int getNextWhiteX(int x, int y) {
  x++;
  while (img.pixels[x + y * img.width] > whiteValue) {
    x++;
    if (x >= img.width) return img.width-1;
  }
  return x-1;
}

// black x
int getFirstNoneBlackX(int x, int y) {
  while (img.pixels[x + y * img.width] > blackValue) {
    x++;
    if (x >= img.width) return -1;
  }
  return x;
}

int getNextBlackX(int x, int y) {
  x++;
  while (img.pixels[x + y * img.width] < blackValue) {
    x++;
    if (x >= img.width) return img.width-1;
  }
  return x-1;
}

// bright x
int getFirstNoneBrightX(int x, int y) {
  while (brightness(img.pixels[x + y * img.width]) < brightValue) {
    x++;
    if (x >= img.width) return -1;
  }
  return x;
}

int getNextBrightX(int x, int y) {
  x++;
  while (brightness(img.pixels[x + y * img.width]) > brightValue) {
    x++;
    if (x >= img.width) return img.width-1;
  }
  return x-1;
}

// dark x
int getFirstNoneDarkX(int x, int y) {
  while (brightness(img.pixels[x + y * img.width]) > darkValue) {
    x++;
    if (x >= img.width) return -1;
  }
  return x;
}

int getNextDarkX(int x, int y) {
  x++;
  while (brightness(img.pixels[x + y * img.width]) < darkValue) {
    x++;
    if (x >= img.width) return img.width-1;
  }
  return x-1;
}

// white y
int getFirstNoneWhiteY(int x, int y) {
  if (y < img.height) {
    while (img.pixels[x + y * img.width] < whiteValue) {
      y++;
      if (y >= img.height) return -1;
    }
  }
  return y;
}

int getNextWhiteY(int x, int y) {
  y++;
  if (y < img.height) {
    while (img.pixels[x + y * img.width] > whiteValue) {
      y++;
      if (y >= img.height) return img.height-1;
    }
  }
  return y-1;
}


// black y
int getFirstNoneBlackY(int x, int y) {
  if (y < img.height) {
    while (img.pixels[x + y * img.width] > blackValue) {
      y++;
      if (y >= img.height) return -1;
    }
  }
  return y;
}

int getNextBlackY(int x, int y) {
  y++;
  if (y < img.height) {
    while (img.pixels[x + y * img.width] < blackValue) {
      y++;
      if (y >= img.height) return img.height-1;
    }
  }
  return y-1;
}

// bright y
int getFirstNoneBrightY(int x, int y) {
  if (y < img.height) {
    while (brightness(img.pixels[x + y * img.width]) < brightValue) {
      y++;
      if (y >= img.height) return -1;
    }
  }
  return y;
}

int getNextBrightY(int x, int y) {
  y++;
  if (y < img.height) {
    while (brightness(img.pixels[x + y * img.width]) > brightValue) {
      y++;
      if (y >= img.height) return img.height-1;
    }
  }
  return y-1;
}

// dark y
int getFirstNoneDarkY(int x, int y) {
  if (y < img.height) {
    while (brightness(img.pixels[x + y * img.width]) > darkValue) {
      y++;
      if (y >= img.height) return -1;
    }
  }
  return y;
}

int getNextDarkY(int x, int y) {
  y++;
  if (y < img.height) {
    while (brightness(img.pixels[x + y * img.width]) < darkValue) {
      y++;
      if (y >= img.height) return img.height-1;
    }
  }
  return y-1;
}
