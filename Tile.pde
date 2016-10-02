class Tile{
  public final color barrenColor = color(0,0,1);
  public final color fertileColor = color(0,0,0.2);
  public final color blackColor = color(0,1,0);
  public final color waterColor = color(0,0,0);
  public final float FOOD_GROWTH_RATE = 1.0;
  
  private double fertility;
  private double foodLevel;
  private final float maxGrowthLevel = 3.0;
  private int posX;
  private int posY;
  private double lastUpdateTime = 0;
  
  public double climateType;
  public double foodType;
  
  Board board;
  
  public Tile(int x, int y, double f, float food, float type, Board b){
    posX = x;
    posY = y;
    fertility = Math.max(0,f);
    foodLevel = Math.max(0,food);
    climateType = foodType = type;
    board = b;
  }
  public double getFertility(){
    return fertility;
  }
  public double getFoodLevel(){
    return foodLevel;
  }
  public void setFertility(double f){
    fertility = f;
  }
  public void setFoodLevel(double f){
    foodLevel = f;
  }
  public void drawTile(float scaleUp, boolean showEnergy){
    stroke(0,0,0,1);
    strokeWeight(2);
    color landColor = getColor();
    fill(landColor);
    rect(posX*scaleUp,posY*scaleUp,scaleUp,scaleUp);
    if(showEnergy){
      if(brightness(landColor) >= 0.7){
        fill(0,0,0,1);
      }else{
        fill(0,0,1,1);
      }
      textAlign(CENTER);
      textFont(font,21);
      text(nf((float)(100*foodLevel),0,2)+" yums",(posX+0.5)*scaleUp,(posY+0.3)*scaleUp);
      text("Clim: "+nf((float)(climateType),0,2),(posX+0.5)*scaleUp,(posY+0.6)*scaleUp);
      text("Food: "+nf((float)(foodType),0,2),(posX+0.5)*scaleUp,(posY+0.9)*scaleUp);
    }
  }
  public void iterate(){
    double updateTime = board.year;
    if(Math.abs(lastUpdateTime-updateTime) >= 0.00001){
      double growthChange = board.getGrowthOverTimeRange(lastUpdateTime,updateTime);
      if(fertility > 1){ // This means the tile is water.
        foodLevel = 0;
      }else{
        if(growthChange > 0){ // Food is growing. Exponentially approach maxGrowthLevel.
          if(foodLevel < maxGrowthLevel){
            double newDistToMax = (maxGrowthLevel-foodLevel)*Math.pow(2.71828182846,-growthChange*fertility*FOOD_GROWTH_RATE);
            double foodGrowthAmount = (maxGrowthLevel-newDistToMax)-foodLevel;
            addFood(foodGrowthAmount,climateType,false);
          }
        }else{ // Food is dying off. Exponentially approach 0.
          removeFood(foodLevel-foodLevel*Math.pow(2.71828182846,growthChange*FOOD_GROWTH_RATE),false);
        }
        /*if(growableTime > 0){
          if(foodLevel < maxGrowthLevel){
            double foodGrowthAmount = (maxGrowthLevel-foodLevel)*fertility*FOOD_GROWTH_RATE*timeStep*growableTime;
            addFood(foodGrowthAmount,climateType);
          }
        }else{
          foodLevel += maxGrowthLevel*foodLevel*FOOD_GROWTH_RATE*timeStep*growableTime;
        }*/
      }
      foodLevel = Math.max(foodLevel,0);
      lastUpdateTime = updateTime;
    }
  }
  public void addFood(double amount, double addedFoodType, boolean canCauseIteration){
    if(canCauseIteration){
      iterate();
    }
    foodLevel += amount;
    /*if(foodLevel > 0){
      foodType += (addedFoodType-foodType)*(amount/foodLevel); // We're adding new plant growth, so we gotta "mix" the colors of the tile.
    }*/
  }
  public void removeFood(double amount, boolean canCauseIteration){
    if(canCauseIteration){
      iterate();
    }
    foodLevel -= amount;
  }
  public color getColor(){
    iterate();
    color foodColor = color((float)(foodType),1,1);
    if(fertility > 1){
      return waterColor;
    }else if(foodLevel < maxGrowthLevel){
      return interColorFixedHue(interColor(barrenColor,fertileColor,fertility),foodColor,foodLevel/maxGrowthLevel,hue(foodColor));
    }else{
      return interColorFixedHue(foodColor,blackColor,1.0-maxGrowthLevel/foodLevel,hue(foodColor));
    }
  }
  public color interColor(color a, color b, double x){
    double hue = inter(hue(a),hue(b),x);
    double sat = inter(saturation(a),saturation(b),x);
    double bri = inter(brightness(a),brightness(b),x); // I know it's dumb to do interpolation with HSL but oh well
    return color((float)(hue),(float)(sat),(float)(bri));
  }
  public color interColorFixedHue(color a, color b, double x, double hue){
    double satB = saturation(b);
    if(brightness(b) == 0){ // I want black to be calculated as 100% saturation
      satB = 1;
    }
    double sat = inter(saturation(a),satB,x);
    double bri = inter(brightness(a),brightness(b),x); // I know it's dumb to do interpolation with HSL but oh well
    return color((float)(hue),(float)(sat),(float)(bri));
  }
  public double inter(double a, double b, double x){
    return a + (b-a)*x;
  }
}
