import processing.video.*;

// Size of each cell in the grid
int cellSize = 40; // min 22
int cellRadius = 8;

// Number of columns and rows in our system
int cols, rows;

// Variable for capture device
Capture video;

float[] rectSizes;
color rectColor = color(100,100,100);
int programMode = 0;
int tableLength;
int sortingIndexI;
int sortingIndexS;
int heapSortingIndex;
boolean newRec = false;
boolean heapIsBuilt = false;
int sortingMethod;
int arrayAccesses = 0;
int comparisons = 0;
int xOffset = 50;
int yOffset = 150;
int startTime;
int endTime;
int monitorsY1 = 150;
int monitorsY2 = 250;
int monitorsY3 = 350;
int monitorsX1 = 1150;
int monitorsX2 = 1150;
int monitorsX3 = 1150;
float barYoffset = 1000;
float barWidth;
float barXoffset;
int selectionSortJ;
int frameNumber = 0;
PImage img;
ArrayList<int[]> ssRecords;
ArrayList<int[]> hsRecords;

void setup() {
  fullScreen();
  // Set up columns and rows
  cols = 1280 / cellSize;
  rows = 720 / cellSize;
  colorMode(RGB, 255, 255, 255, 100);
  rectMode(CENTER);
  rectSizes = new float[cols*rows];
  tableLength = cols*rows;
  barWidth = (width)/rectSizes.length;
  barXoffset = (width - (barWidth*rectSizes.length)) / 2;
  ssRecords = new ArrayList<int[]>();
  hsRecords = new ArrayList<int[]>();
  
  // This the default video input, see the GettingStartedCapture 
  // example if it creates an error
  video = new Capture(this, 1280, 720);
  
  // Start capturing the images from the camera
  video.start();  

  background(0);
}

void draw() {  
  if (video.available()) {
    background(0, 0, 0);
    textSize(38);
    if(programMode == 0) { 
      readVideo();
      fill(230);
      text("High scores - t", monitorsX1 + 300, monitorsY1 + 200);
      text("Run insertion sort - i", monitorsX2 + 300, monitorsY2 + 200);
      text("Run heapsort - h", monitorsX3 + 300, monitorsY3 + 200);
      text("Camera view - c", monitorsX3 + 300, monitorsY3 + 300);
    }
    else if(programMode == 1){ // sorting
      if(sortingMethod == 0) {
        hSort(); // heapsort
      }
      else {
        iSort(); // insertion
      }
      
      image(img,100,0,900,506);
      drawBars();
      
      if((sortingMethod == 2 && sortingIndexS == tableLength) ||
         (sortingMethod == 0 && heapSortingIndex == 0)) {
        
        endTime = millis() - startTime;
        
        updateRecords();
        programMode = 2; // high scores
        drawBars();
      }
      
      int currentTime = millis() - startTime;
      fill(230);
      text("Comparisons: " + str(comparisons), monitorsX1, monitorsY1);
      text("Array accesses: " + str(arrayAccesses), monitorsX2, monitorsY2);
      text("Timer: " + str(currentTime) + " ms", monitorsX3, monitorsY3);
    }
    else { // high scores
      delay(2500); // 
      drawHighScores();
    }
  }
}


void updateRecords() {
  if(sortingMethod == 2) {
    int i = 0;
    while(i < ssRecords.size() && comparisons > ssRecords.get(i)[1] && arrayAccesses > ssRecords.get(i)[2]) {
      i++;
    }
    if(i <= ssRecords.size()) newRec = true;
    int[] newRecord = {frameNumber,comparisons,arrayAccesses,endTime};
    ssRecords.add(i,newRecord);
  }
  if(sortingMethod == 0) {
    int i = 0;
    while(i < hsRecords.size() && comparisons > hsRecords.get(i)[1] && arrayAccesses > hsRecords.get(i)[2]) {
      i++;
    }
    if(i <= hsRecords.size()) newRec = true;
    int[] newRecord = {frameNumber,comparisons,arrayAccesses,endTime};
    hsRecords.add(i,newRecord);
  }
  
  frameNumber++;
}


void drawHighScores() {
  stroke(230);
  strokeWeight(0.5);
  line(width/2,0,width/2,height);
  int ssScoreX = 50;
  int betweenScores = 100;
  int hsScoreX = 50 + width/2;
  textSize(30);
  text("Insertion sort high scores", width/4 - 150, 35);
  text("Heapsort high scores", width/2 + width/4 - 100, 35);
  for(int i = 0; (i < ssRecords.size() && i < 3); i++) {
    img = loadImage("/data/testPicture" + str(ssRecords.get(i)[0]) + ".jpg");
    PImage cropped = img.get(50,150,1280,720);
    image(cropped,ssScoreX,betweenScores,400,225);
    if(newRec && (ssRecords.get(i)[0] == (frameNumber - 1))) fill(0,204,0);
    text("Comparisons: " + str(ssRecords.get(i)[1]), width/4, betweenScores+50);
    betweenScores += 70;
    text("Array accesses: " + str(ssRecords.get(i)[2]), width/4, betweenScores+50);
    betweenScores += 70;
    fill(230);
    text("Running time: " + str(ssRecords.get(i)[3]) + " ms", width/4, betweenScores+50);
    betweenScores += 160;
  }
  
  betweenScores = 100;
  for(int i = 0; (i < hsRecords.size() && i < 3); i++) {
    img = loadImage("/data/testPicture" + str(hsRecords.get(i)[0]) + ".jpg");
    PImage cropped = img.get(50,150,1280,720);
    image(cropped,hsScoreX,betweenScores,400,225);
    if(newRec && (hsRecords.get(i)[0] == (frameNumber - 1))) fill(0,204,0);
    text("Comparisons: " + str(hsRecords.get(i)[1]), width/4 + hsScoreX, betweenScores+50);
    betweenScores += 70;
    text("Array accesses: " + str(hsRecords.get(i)[2]), width/4 + hsScoreX, betweenScores+50);
    betweenScores += 70;
    fill(230);
    text("Running time: " + str(hsRecords.get(i)[3]) + " ms", width/4 + hsScoreX, betweenScores+50);
    betweenScores += 160;
  }
}


void readVideo() {
    video.read();
    video.loadPixels();
    // Begin loop for columns
    for (int i = 0; i < cols;i++) {
      // Begin loop for rows
      for (int j = 0; j < rows;j++) {

        int x = i * cellSize;
        int y = j * cellSize;
        int loc = (video.width - x - 1) + y*video.width; // Reversing x to mirror the image
        color c = video.pixels[loc];
        float sz = (brightness(c) / 255.0) * cellSize;
        rectSizes[i*rows+j] = sz;
        
        fill(rectColor, sz*10);
        noStroke();
        rect(x + cellSize/2 + xOffset, y + cellSize/2 + yOffset, sz, sz, cellRadius);
      }
    }
}


void hSort() {
  if(!heapIsBuilt) {
    for (int i = tableLength / 2 - 1; i >= 0; i--) 
        heapify(rectSizes, tableLength, i);
    heapIsBuilt = true;
  }
  else {
    float temp = rectSizes[0]; 
    rectSizes[0] = rectSizes[heapSortingIndex]; 
    rectSizes[heapSortingIndex] = temp; 
 
    arrayAccesses += 4;
    heapify(rectSizes, heapSortingIndex, 0);
  }
  
  heapSortingIndex --;
}


void iSort() {
  float k = rectSizes[sortingIndexS];
  int j = sortingIndexS - 1; 

  while (j >= 0 && rectSizes[j] > k) { 
      rectSizes[j + 1] = rectSizes[j];
      j = j - 1;
      selectionSortJ = j;
      arrayAccesses += 3;
      comparisons++;
      //drawBars();
  }
  
  rectSizes[j + 1] = k;
  arrayAccesses += 2;
  
  sortingIndexS++;
}


void heapify(float arr[], int n, int i) 
{ 
    int largest = i;  // Initialize largest as root 
    int l = 2*i + 1;  // left = 2*i + 1 
    int r = 2*i + 2;  // right = 2*i + 2 

    // If left child is larger than root 
    if (l < n && arr[l] > arr[largest]) 
        largest = l; 

    // If right child is larger than largest so far 
    if (r < n && arr[r] > arr[largest]) 
        largest = r;

    arrayAccesses += 4;
    comparisons += 2;
    // If largest is not root 
    if (largest != i) 
    { 
        float swap = arr[i]; 
        arr[i] = arr[largest]; 
        arr[largest] = swap; 
        arrayAccesses += 4;
        
        // Recursively heapify the affected sub-tree 
        heapify(arr, n, largest); 
    } 
} 


void keyPressed() {
  // sorting begins
  if (key == 'h' && programMode == 0) {
    heapSortingIndex = tableLength;
    sortingMethod = 0;
    programMode = 1;
    startTime = millis();
    saveFrame("/data/testPicture" + str(frameNumber) + ".jpg");
    img = loadImage("/data/testPicture" + str(frameNumber) + ".jpg");
  }
  if(key == 'i' && programMode == 0) {
    sortingIndexS = 1;
    sortingMethod = 2;
    programMode = 1;
    startTime = millis();
    saveFrame("/data/testPicture" + str(frameNumber) + ".jpg");
    img = loadImage("/data/testPicture" + str(frameNumber) + ".jpg");
  }
  if (key == 't' && programMode == 0) {
    programMode = 2; // high scores
  }
  if(key == 'c') { // reset
    programMode = 0;
    rectSizes = new float[cols*rows];
    sortingIndexS = 0;
    arrayAccesses = 0;
    comparisons = 0;
    heapIsBuilt = false;
    newRec = false;
  }
}


void drawBars() {
  
  //println(barWidth, rectSizes.length, barWidth*rectSizes.length, width-600);
  rectMode(CORNER);
  barXoffset = (width - (barWidth*rectSizes.length)) / 2;
  
  for (int i = 0; i < rectSizes.length; i++) {
    float sz = rectSizes[i];
    if(sortingMethod == 2 && i < sortingIndexS) {
      color from = color(233,39,0);
      color to = color(0,204,0);
      float amt = map(float(sortingIndexS),0.0,float(rectSizes.length),0.0,1.0);
      fill(lerpColor(from,to,amt));
    }
    else if(sortingMethod == 1 && i < sortingIndexI) {
      color from = color(233,39,0);
      color to = color(0,204,0);
      float amt = map(float(sortingIndexI),0.0,float(rectSizes.length),0.0,1.0);
      fill(lerpColor(from,to,amt));
    }
    else if(sortingMethod == 0 && i > heapSortingIndex) {
      color from = color(233,39,0);
      color to = color(0,204,0);
      float amt = map(float(heapSortingIndex),float(rectSizes.length),0.0,0.0,1.0);
      fill(lerpColor(from,to,amt));
    }
    else {
      fill(233,39,0);
    }
    noStroke();
    float barLength = map(sz,0.0,100.0,0.0,900.0);
    rect(barXoffset, barYoffset - barLength, barWidth, barLength);
    barXoffset += barWidth;
  }
}
