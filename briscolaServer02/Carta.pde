class Carta{
  int val;
  int valfalso;
  int punteggio;
  int seme;
  String proprietario;
  
  /*SEME:
  0 mattoni
  1 cuori
  2 picche
  3 fiori
  */
  
  
  Carta(int valore, int seme){
    this.seme=seme;
    val=valore;
    valfalso=val;
    if(valore==1){
      punteggio=11;
      valfalso=11;
    }
    else{
      if(valore==3){
        punteggio=10;
        valfalso=10;
      }
      else{
        if(valore==8){
          punteggio=2;
          valfalso=2;
        }
        else{
          if(valore==9){
            punteggio=3;
            valfalso=3;
          }
          else{
            if(valore==10){
              punteggio=4;
              valfalso=4;
            }
            else
              punteggio=0;
          }
        }
      }
    }
  }
  
  Carta(int valore, int seme, String inv){
    this.seme=seme;
    val=valore;
    valfalso=val;
    if(valore==1){//asso
      punteggio=11;
      valfalso=20;
    }
    else{
      if(valore==3){// tre
        punteggio=10;
        valfalso=19;
      }
      else{
        if(valore==8){// Jack
          punteggio=2;
          valfalso=16;
        }
        else{
          if(valore==9){ // Donna
            punteggio=3;
            valfalso=17;
          }
          else{
            if(valore==10){ // Re
              punteggio=4;
              valfalso=18;
            }
            else
              punteggio=0;
          }
        }
      }
    }
    proprietario=inv;
  }
  
  void draw(){
    switch(seme){
      case 0:println(val, "M", punteggio, proprietario, valfalso);break;
      case 1:println(val, "C", punteggio, proprietario, valfalso);break;
      case 2:println(val, "P", punteggio, proprietario, valfalso);break;
      case 3:println(val, "F", punteggio, proprietario, valfalso);break;
    }
  }
  
  String toString(){
    return new String(new Integer(val).toString()+" "+new Integer(seme).toString()+" "+new Integer(punteggio).toString());
  }
  
}
