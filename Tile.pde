class Tile{
  public final color barrenColor = color(0,0,1);
  public final color fertileColor = color(0,0,0.2);
  public final color blackColor = color(0,1,0);
  public final color waterColor = color(0,0,0);
  public final float FOOD_GROWTH_RATE = 1.0;
  
  private float fertility;
  private float foodLevel;
  private final float maxGrowthLevel = 1.0;
  private int posX;
  private int posY;
  
  public float climateType;
  public float foodType;
  
  public Tile(int x, int y, float f, float food, float type){
    posX = x;
    posY = y;
    fertility = max(0,f);
    foodLevel = max(0,food);
    climateType = foodType = type;
  }
  public float getFertility(){
    return fertility;
  }
  public float getFoodLevel(){
    return foodLevel;
  }
  public void setFertility(float f){
    fertility = f;
  }
  public void setFoodLevel(float f){
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
      text(nf(100*foodLevel,0,2)+" yums",(posX+0.5)*scaleUp,(posY+0.3)*scaleUp);
      text("Clim: "+nf(climateType,0,2),(posX+0.5)*scaleUp,(posY+0.6)*scaleUp);
      text("Food: "+nf(foodType,0,2),(posX+0.5)*scaleUp,(posY+0.9)*scaleUp);
    }
  }
  public void iterate(double timeStep, float growableTime){
    if(fertility > 1){
      foodLevel = 0;
    }else{
      if(growableTime > 0){
        if(foodLevel < maxGrowthLevel){
          double foodGrowthAmount = (maxGrowthLevel-foodLevel)*fertility*FOOD_GROWTH_RATE*timeStep*growableTime;
          addFood(foodGrowthAmount,climateType);
        }
      }else{
        foodLevel += maxGrowthLevel*foodLevel*FOOD_GROWTH_RATE*timeStep*growableTime;
      }
    }
    foodLevel = max(foodLevel,0);
  }
  public void addFood(double amount, double addedFoodType){
    foodLevel += amount;
    if(foodLevel > 0){
      foodType += (addedFoodType-foodType)*(amount/foodLevel); // We're adding new plant growth, so we gotta "mix" the colors of the tile.
    }
  }
  public color getColor(){
    color foodColor = color(foodType,1,1);
    if(fertility > 1){
      return waterColor;
    }else if(foodLevel < maxGrowthLevel){
      return interColorFixedHue(interColor(barrenColor,fertileColor,fertility),foodColor,foodLevel/maxGrowthLevel,hue(foodColor));
    }else{
      return interColorFixedHue(foodColor,blackColor,1.0-maxGrowthLevel/foodLevel,hue(foodColor));
    }
  }
  public color interColor(color a, color b, float x){
    float hue = inter(hue(a),hue(b),x);
    float sat = inter(saturation(a),saturation(b),x);
    float bri = inter(brightness(a),brightness(b),x); // I know it's dumb to do interpolation with HSL but oh well
    return color(hue,sat,bri);
  }
  public color interColorFixedHue(color a, color b, float x, float hue){
    float satB = saturation(b);
    if(brightness(b) == 0){ // I want black to be calculated as 100% saturation
      satB = 1;
    }
    float sat = inter(saturation(a),satB,x);
    float bri = inter(brightness(a),brightness(b),x); // I know it's dumb to do interpolation with HSL but oh well
    return color(hue,sat,bri);
  }
  public float inter(float a, float b, float x){
    return a + (b-a)*x;
  }
}
