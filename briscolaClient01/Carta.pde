class Carta{
  PImage img;
  int val;
  int punteggio;
  int seme;
  int x,y;
  
  /*SEME:
  0 mattoni
  1 cuori
  2 picche
  3 fiori
  */
  
  
  Carta(String s,int x, int y){
    this.x=x;
    this.y=y;
    String[] parti=s.split(" ");   // valore[1,10] seme[0,3] punteggio[..]
    val=Integer.parseInt(parti[0]);
    seme=Integer.parseInt(parti[1]);
    punteggio=Integer.parseInt(parti[2]);
 
    switch(seme){//Caricamento immagine carta
      case 0://mattoni
        img=loadImage("../carte/"+val+"M.png");
      break;
      case 1://cuori
        img=loadImage("../carte/"+val+"C.png");
      break;
      case 2://picche
        img=loadImage("../carte/"+val+"P.png");
      break;
      case 3://fiori
        img=loadImage("../carte/"+val+"F.png");
      break;      
    

    } 
    
  }
  
  void draw(){
    image(img,x,y,50,50);
  }
  
  String toString(){
    return new String(new Integer(val).toString()+" "+new Integer(seme).toString());
  }
  
  boolean isClicked(){
    if(mousePressed){
      if(mouseX>=x && mouseX<=x+50){
        if(mouseY>=y && mouseY<=y+50)
          return true;
      }
    }
    return false;
  }
  
  boolean equals(Carta c){
    return (c.val==val && c.seme==seme);
  }
  
  void setX(int x){
    this.x=x;
  }
}
