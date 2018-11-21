color backgroundColor = color(0,100,30);
color cellColor = color (0,200,0);

int board[][];
int d[][];
int path[][];
int boardlul[];
color colors[] = {color(255),color(255,0,0),color(0,255,0),color(0,0,255),color(0,255,255)};

final int rows = 8;
final int columns = 10;

float cellSize ;
float diameter;


int mX, mXLive,lastX;
int mY, mYLive,lastY;
int lastPlay=-1;

int delay = 500;
int t1;
Boolean clicked=false;


void setup(){
  size(800,600);
  background(backgroundColor);
  cellSize = (width-width*0.1)/12;
  diameter = cellSize - 10;
  board = new int[columns][rows]; 
  d = new int[columns][rows];
  path = new int[columns][rows];
    fillBoardlul();
   ints_shuffle(boardlul);
   board[boardlul[0]-(boardlul[0]/columns)*columns][boardlul[0]/columns]=int(random(1,5));
   board[boardlul[1]-(boardlul[1]/columns)*columns][boardlul[1]/columns]=int(random(1,5));
   board[boardlul[2]-(boardlul[2]/columns)*columns][boardlul[2]/columns]=int(random(1,5)); 
   
   

  drawBoard();
}


void update(){
  //check all directions lul

  int z=0;
  int count = countWhile(board,rows,columns,board[mX][mY],mY,mX,0,1)+countWhile(board,rows,columns,board[mX][mY],mY,mX,0,-1)-1;
    if(count>=5){
     deleteCells(board,rows,columns,board[mX][mY],mY,mX,0,1);
     deleteCells(board,rows,columns,board[mX][mY],mY,mX,0,-1);
     z=1;
    }
    count = countWhile(board,rows,columns,board[mX][mY],mY,mX,1,0)+countWhile(board,rows,columns,board[mX][mY],mY,mX,-1,0)-1;
      if(count>=5){
        deleteCells(board,rows,columns,board[mX][mY],mY,mX,1,0);
        deleteCells(board,rows,columns,board[mX][mY],mY,mX,-1,0);
        z=1;
      }
    count = countWhile(board,rows,columns,board[mX][mY],mY,mX,1,1)+countWhile(board,rows,columns,board[mX][mY],mY,mX,-1,-1)-1; //sum of both diretion counts -1 in order to not count the last cell pressed
    if(count>=5){
     deleteCells(board,rows,columns,board[mX][mY],mY,mX,1,1);
     deleteCells(board,rows,columns,board[mX][mY],mY,mX,-1,-1);
     z=1;
    }
    count = countWhile(board,rows,columns,board[mX][mY],mY,mX,-1,1)+countWhile(board,rows,columns,board[mX][mY],mY,mX,1,-1)-1;
    if(count>=5){
      deleteCells(board,rows,columns,board[mX][mY],mY,mX,-1,1);
      deleteCells(board,rows,columns,board[mX][mY],mY,mX,1,-1);
      z=1;
    }
    if(z==1)
      board[mX][mY]=0; //only after deleting one or more lines delete the last cell pressed -> !!
    z=0;   
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   if(mouseY>height*0.05 && mouseY<height*0.05+cellSize*rows && mouseX>width*0.05 && mouseX<width*0.05+cellSize*columns){ //board restrictions
   mXLive = int((mouseX - width*0.05)/cellSize);
   mYLive = int((mouseY - height*0.05)/cellSize);
  }
   for(int j = 0; j<columns ; j++){
   println();
   for(int i= 0; i<rows; i++){
    path[j][i]=0; 
   }  
  }
       
}

void draw(){
  drawBoard(); 
  update();
  allDistances(board,rows,columns,mY,mX,d);
  shortestPath(board,rows,columns,d,mYLive,mXLive,path);
  fillBoardlul();
  if(lastPlay>0)
  drawPath();
  
    if(clicked){
    textSize(50);
    fill(255,130,31);
    text("you lose bruh", width/2-100,height/2);}
  //println((countWhile(board,rows,columns,1,mX,mY,0,-1)+countWhile(board,rows,columns,1,mX,mY,0,1))-1);
  //println((countWhile(board,rows,columns,1,mX,mY,1,0)+countWhile(board,rows,columns,1,mX,mY,-1,0))-1);

}

void mousePressed(){
  t1=millis();
if(mouseY>height*0.05 && mouseY<height*0.05+cellSize*rows && mouseX>width*0.05 && mouseX<width*0.05+cellSize*columns){ //board restrictions
   mX = int((mouseX - width*0.05)/cellSize);
   mY = int((mouseY - height*0.05)/cellSize);
  
  boolean bugfix=false;
if(board[mX][mY]==0 && lastPlay>0 && d[mXLive][mYLive]!=-1){
   board[mXLive][mYLive]=lastPlay; 
   lastPlay=-1;
   board[lastX][lastY]=0;
   ints_shuffle(boardlul);
   try {board[boardlul[0]-(boardlul[0]/columns)*columns][boardlul[0]/columns]=int(random(1,5));} catch (Exception e) {clicked=true;};
   try {board[boardlul[1]-(boardlul[1]/columns)*columns][boardlul[1]/columns]=int(random(1,5));} catch (Exception e) {clicked=true;};
   try {board[boardlul[2]-(boardlul[2]/columns)*columns][boardlul[2]/columns]=int(random(1,5));} catch (Exception e) {clicked=true;};
   bugfix=true;
 }
if(board[mX][mY]!=0 && !bugfix)
lastPlay=board[mX][mY];
 lastX=mX;
 lastY=mY;
}

}

int countWhile(int[][] m, int rows, int columns, int tempColor, int r, int c, int dv, int dh){ //counts the number of same color rectangles in a row in a certain direction dv, dh
                                                                              //dv and dh are direction coordinates - can only take values of 0 1 or -1
                                                                              //ex : right => dv = 0, dh = 1 ; left => dv = 0, dh = -1; up => dv = -1 , dh = 0;
  int result = 0;
  //println(" color" ,board[r][c]);
  if(tempColor!=0){
    while(c>=0 && r >=0 && r<rows && c<columns && m[c][r]==tempColor){
        c+=dh;
        r+=dv;
        result++;
        //println(c," ",r," ",dv," ",dh);    
    }
  }
    //println(result);
    return result;   
}

void deleteCells(int[][] m, int rows, int columns, int tempColor, int r, int c, int dv, int dh){ //arguments work in the same ways as countWhile function
   r = r+dv;
   c=c+dh;
    while(c>=0 && r >=0 && r<rows &&  c< columns && m[c][r]==tempColor){ //this time puts a 0 on the matrix cells in order to delete the cells
     m[c][r]=0;
     c+=dh;
     r+=dv;
    }
}

int getNumber(int[][]d, int rows, int columns, int r, int c, int dv, int dh){ //given a point r,c and a direction dv, dh
 int result=0;                                                               //return number next to r,c in the given direction
   if(r+dv>=0 && r+dv<rows && c+dh>=0 && c+dh<columns)
     result = d[c+dh][r+dv];
 return result;
}

void allDistances(int[][]m, int rows, int columns, int r, int c, int[][] d){ //fill matrix d with all the distances to the point r,c
 
  for(int j = 0; j<columns ; j++){
   for(int i= 0; i<rows; i++){
    d[j][i]= -1; 
   }
  }

  d[c][r]=0;
    
    if(c+1<columns && m[c+1][r]==0)
      d[c+1][r]=1;
    if(c-1>-1  && m[c-1][r]==0)
      d[c-1][r]=1;
    if(r+1<rows  && m[c][r+1]==0)
      d[c][r+1]=1;
    if(r-1>-1  && m[c][r-1]==0)
      d[c][r-1]=1;
   /* if(r-1>-1 && c-1>-1  && m[c-1][r-1]==0)
      d[c-1][r-1]=1;
    if(r+1<rows && c+1<columns  && m[c+1][r+1]==0)
      d[c+1][r+1]=1;
    if(r-1>-1 && c+1<columns  && m[c+1][r-1]==0)
      d[c+1][r-1]=1;
    if(r+1<rows && c-1>-1  && m[c-1][r+1]==0)
      d[c-1][r+1]=1;*/
 
  int x=1; 
  Boolean z = true;
  while(z){
  z = false;
  for(int j = 0; j<columns; j++){
   for(int i = 0; i<rows; i++){
     if(d[j][i] == x){
       if(getNumber(d,rows,columns,i,j,0,1)==-1 && m[j+1][i]==0){
         d[j+1][i]=x+1;
         z = true; 
       }
       if(getNumber(d,rows,columns,i,j,0,-1)==-1 && m[j-1][i]==0){
         d[j-1][i]=x+1;
         z = true;
       }
       if(getNumber(d,rows,columns,i,j,1,0)==-1 && m[j][i+1]==0){
         d[j][i+1]=x+1;
         z = true;
       }
       if(getNumber(d,rows,columns,i,j,-1,0)==-1 && m[j][i-1]==0){
         d[j][i-1]=x+1;
         z = true;
       }
       /*if(getNumber(d,rows,columns,i,j,-1,-1)==-1 && m[j-1][i-1]==0){
        d[j-1][i-1]=x+1;
        z = true;
       }
       if(getNumber(d,rows,columns,i,j,1,1)==-1 && m[j+1][i+1]==0){
        d[j+1][i+1]=x+1;
        z = true;
       }
       if(getNumber(d,rows,columns,i,j,-1,1)==-1 && m[j+1][i-1]==0){
         d[j+1][i-1]=x+1;
         z = true;
       }
       if(getNumber(d,rows,columns,i,j,1,-1)==-1 && m[j-1][i+1]==0){
         d[j-1][i+1]=x+1;
         z = true;*/
       }
     }
     }
     x++;
    }
    
  }



void shortestPath(int[][] m, int rows, int columns, int [][] d, int r, int c, int[][] p){
  int x = d[c][r];
  p[c][r] = 1;
  while(x>0){
   if(getNumber(d,rows,columns,r,c,0,1)==x-1 && c+1<columns ){
    p[c+1][r]=1;
    c+=1;
   }
   else if(getNumber(d,rows,columns,r,c,0,-1)==x-1 && c-1>-1  ){
     p[c-1][r]=1;
     c-=1;
   }
   else if(getNumber(d,rows,columns,r,c,1,0)==x-1 && r+1<rows  ){
    p[c][r+1]=1;
    r+=1;
   }
   else if(getNumber(d,rows,columns,r,c,-1,0)==x-1 && r-1>-1  ){
    p[c][r-1]=1;
    r-=1;
   }
   x--;
  }
 
}

void drawPath(){
  for(int j = 0; j<columns; j++){
  for(int i = 0; i<rows; i++){
    if(path[j][i]==1){
      fill(colors[board[lastX][lastY]],80);
      noStroke();
      ellipseMode(CORNER);
      ellipse((width*0.05)+diameter/4+cellSize*j,height*0.05+diameter/4+cellSize*i,diameter/2,diameter/2);
      stroke(0);
    }
   }
 }
}

void fillBoardlul(){
  int count = 0,  x=0;
 for(int j = 0; j<columns; j++){
   for(int i = 0; i<rows; i++){
    if(board[j][i]==0)
      count++;   
   }  
  }
  boardlul = new int[count];
  for(int j = 0; j<columns; j++){
   for(int i = 0; i<rows; i++){
     if(board[j][i]==0){
       boardlul[x++]= i*columns+j;
     }
   }
  }
}

void ints_shuffle(int[] a)
{
  int n = a.length;
  for (int i = 0; i < n-1; i++)
    ints_exchange(a, i, i+int(random(n-1-i)));
}

void ints_exchange(int[] a, int x, int y)
{
  int m = a[x];
  a[x] = a[y];
  a[y] = m;
}


void drawBoard(){ 
 for (int j = 0; j< columns; j++){
   for(int i = 0; i< rows; i++){
    
     //print(board[j][i]," ");
     if(board[j][i]==0){ //draws empty rectangle if 0
     strokeWeight(2);
       fill(255);
       rect((width*0.05)+cellSize*j,height*0.05+cellSize*i,cellSize,cellSize);
     }
     if(board[j][i]!=0){ //colored rectangle if 1
     strokeWeight(2);
       fill(255);
       rect((width*0.05)+cellSize*j,height*0.05+cellSize*i,cellSize,cellSize);
     strokeWeight(0.5);
       fill(colors[board[j][i]]);
       ellipseMode(CORNER);
       ellipse((width*0.05)+5+cellSize*j,height*0.05+5+cellSize*i,diameter,diameter);
     }          
   }//println();
 }
}
