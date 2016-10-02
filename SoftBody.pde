class SoftBody{
  double px;
  double py;
  double vx;
  double vy;
  double energy;
  final float ENERGY_DENSITY = 1.0/(0.2*0.2*PI); //set so when a creature is of minimum size, it equals one.
  double density;
  double hue;
  double saturation;
  double brightness;
  double birthTime;
  boolean isCreature = false;
  final float FRICTION = 0.03;
  final float COLLISION_FORCE = 0.1;
  final float FIGHT_RANGE = 2.0;
  double fightLevel = 0;
  
  int prevSBIPMinX;
  int prevSBIPMinY;
  int prevSBIPMaxX;
  int prevSBIPMaxY;
  int SBIPMinX;
  int SBIPMinY;
  int SBIPMaxX;
  int SBIPMaxY;
  ArrayList<SoftBody> colliders;
  Board board;
  public SoftBody(double tpx, double tpy, double tvx, double tvy, double tenergy, double tdensity,
  double thue, double tsaturation, double tbrightness, Board tb, double bt){
    px = tpx;
    py = tpy;
    vx = tvx;
    vy = tvy;
    energy = tenergy;
    density = tdensity;
    hue = thue;
    saturation = tsaturation;
    brightness = tbrightness;
    board = tb;
    setSBIP(false);
    setSBIP(false); // just to set previous SBIPs as well.
    birthTime = bt;
  }
  public void setSBIP(boolean shouldRemove){
    double radius = getRadius()*FIGHT_RANGE;
    prevSBIPMinX = SBIPMinX;
    prevSBIPMinY = SBIPMinY;
    prevSBIPMaxX = SBIPMaxX;
    prevSBIPMaxY = SBIPMaxY;
    SBIPMinX = xBound((int)(Math.floor(px-radius)));
    SBIPMinY = yBound((int)(Math.floor(py-radius)));
    SBIPMaxX = xBound((int)(Math.floor(px+radius)));
    SBIPMaxY = yBound((int)(Math.floor(py+radius)));
    if(prevSBIPMinX != SBIPMinX || prevSBIPMinY != SBIPMinY || 
    prevSBIPMaxX != SBIPMaxX || prevSBIPMaxY != SBIPMaxY){
      if(shouldRemove){
        for(int x = prevSBIPMinX; x <= prevSBIPMaxX; x++){
          for(int y = prevSBIPMinY; y <= prevSBIPMaxY; y++){
            if(x < SBIPMinX || x > SBIPMaxX || 
            y < SBIPMinY || y > SBIPMaxY){
              board.softBodiesInPositions[x][y].remove(this);
            }
          }
        }
      }
      for(int x = SBIPMinX; x <= SBIPMaxX; x++){
        for(int y = SBIPMinY; y <= SBIPMaxY; y++){
          if(x < prevSBIPMinX || x > prevSBIPMaxX || 
          y < prevSBIPMinY || y > prevSBIPMaxY){
            board.softBodiesInPositions[x][y].add(this);
          }
        }
      }
    }
  }
  public int xBound(int x){
    return Math.min(Math.max(x,0),board.boardWidth-1);
  }
  public int yBound(int y){
    return Math.min(Math.max(y,0),board.boardHeight-1);
  }
  public double xBodyBound(double x){
    double radius = getRadius();
    return Math.min(Math.max(x,radius),board.boardWidth-radius);
  }
  public double yBodyBound(double y){
    double radius = getRadius();
    return Math.min(Math.max(y,radius),board.boardHeight-radius);
  }
  public void collide(double timeStep){
    colliders = new ArrayList<SoftBody>(0);
    for(int x = SBIPMinX; x <= SBIPMaxX; x++){
      for(int y = SBIPMinY; y <= SBIPMaxY; y++){
        for(int i = 0; i < board.softBodiesInPositions[x][y].size(); i++){
          SoftBody newCollider = (SoftBody)board.softBodiesInPositions[x][y].get(i);
          if(!colliders.contains(newCollider) && newCollider != this){
            colliders.add(newCollider);
          }
        }
      }
    }
    for(int i = 0; i < colliders.size(); i++){
      SoftBody collider = colliders.get(i);
      float distance = dist((float)px,(float)py,(float)collider.px,(float)collider.py);
      double combinedRadius = getRadius()+collider.getRadius();
      if(distance < combinedRadius){
        double force = combinedRadius*COLLISION_FORCE;
        vx += ((px-collider.px)/distance)*force/getMass();
        vy += ((py-collider.py)/distance)*force/getMass();
      }
    }
    fightLevel = 0;
  }
  public void applyMotions(double timeStep){
    px = xBodyBound(px+vx*timeStep);
    py = yBodyBound(py+vy*timeStep);
    vx *= (1-FRICTION/getMass());
    vy *= (1-FRICTION/getMass());
    setSBIP(true);
  }
  public void drawSoftBody(float scaleUp){
    double radius = getRadius();
    stroke(0);
    strokeWeight(2);
    fill((float)hue, (float)saturation, (float)brightness);
    ellipseMode(RADIUS);
    ellipse((float)(px*scaleUp),(float)(py*scaleUp),(float)(radius*scaleUp),(float)(radius*scaleUp));
  }
  public double getRadius(){
    if(energy <= 0){
      return 0;
    }else{
      return Math.sqrt(energy/ENERGY_DENSITY/Math.PI);
    }
  }
  public double getMass(){
    return energy/ENERGY_DENSITY*density;
  }
}
