//movement variables
float   movement_speed = 3.0;
PVector movement_direction = new PVector(movement_speed, 0);

//skeleton point coordinates
PVector snout  = new PVector(200, 200);
PVector head   = new PVector(200, 200);
PVector spine1 = new PVector(250, 200);
PVector spine2 = new PVector(300, 200);
PVector spine3 = new PVector(350, 200);
PVector spine4 = new PVector(400, 200);
PVector tail1  = new PVector(250, 200);
PVector tail2  = new PVector(300, 200);
PVector tail3  = new PVector(350, 200);
PVector tail4  = new PVector(400, 200);

//main body shadow offset
PVector shadow_offset = new PVector(-5, 5);

//lizard steering controls
float maxturn = 0.05;
float turnlerp = 0.15;
float turn = 0;
float tongue_forward = 10;
float tongueside = 0;

//soft border settings
float border = 50;
float push_speed = 0.1;

//input booleans
boolean left        = false;
boolean right       = false;
boolean tongue      = false;
boolean changecolor = false;

//color related variables
color eyecolor      = #000000;
color tongue_color  = #ff5555;
color liz_body      = #B6DB19;
color liz_legs      = #93AF15;
color grass         = #59c135;
color grass_shadow  = #14a02e;
color liz_shadow = color(0, 0, 100, 100);
float hue = 0.2;


//leg lockers
boolean leg_fr_down = false;
boolean leg_fl_down = false;
boolean leg_br_down = false;
boolean leg_bl_down = false;

//feet positions
PVector leg_fr_pos = new PVector(200, 200);
PVector leg_fl_pos = new PVector(200, 200);
PVector leg_br_pos = new PVector(200, 200);
PVector leg_bl_pos = new PVector(200, 200);

//leg stats
float leg_length  = 30;
float leg_angle   = PI/12;
float leg_speed   = 10;
float body_sway   = 2;
float tongue_wave = 20;
float tongue_amp  = 0.05;

//leg targets
PVector leg_fr_target = new PVector(200, 200);
PVector leg_fl_target = new PVector(200, 200);
PVector leg_br_target = new PVector(200, 200);
PVector leg_bl_target = new PVector(200, 200);


void setup() {
  size(400,400);
  frameRate(60);
  smooth(0);
  hue = random(0,1);//obligatory random
  change_color();//to replace default body and leg colors
}


void draw() {
  draw_background();//green and text
  move_head(); //move according to player input
  push_head(); //avoid walls
  move_spine();//move main body
  move_legs(); //handles leg movement
  leg_shadow(grass_shadow, -3, 3); //leg shadows
  draw_body_shadow(grass_shadow);  //mainbody shadows
  draw_legs(liz_legs);//draws legs
  draw_body(liz_body);//draws mainbody
}


//function used to create rope physics for the spine
//returns a point on the edge of the distance circle around anchor if point is out of range
PVector anchor(PVector point_, PVector anchor_, float distance_) {
  PVector point = new PVector(point_.x, point_.y);   //duplicates variable to not infulence the inputs
  PVector anchor = new PVector(anchor_.x, anchor_.y);//yes, it does do that, its a problem
  float distance = distance_;

  PVector newpoint = new PVector(0, 0); 
  newpoint = new PVector(point_.x, point_.y); //returns input point if in range of anchor

  //returns point on the edge of anchor radius if not in range
  if (point.sub(anchor).mag()>distance) {
    point = new PVector(point_.x, point_.y);
    anchor = new PVector(anchor_.x, anchor_.y);
    PVector tosub = anchor.sub(point).normalize().mult(distance);
    anchor = new PVector(anchor_.x, anchor_.y);
    newpoint = anchor.sub(tosub);
  }

  return (newpoint);
}


//interprets player input
void move_head() {
  int dir = 0;//turn direction variable to cancel out conflicting inputs
  if (left) {dir--;}
  if (right) {dir++;}

  if (tongue) {tongue_forward = lerp(tongue_forward, 10, turnlerp);} 
  else {tongue_forward = lerp(tongue_forward, 0, turnlerp);}

  if(changecolor){change_color();}
  
  turn = lerp(turn, maxturn*dir, turnlerp);//changes per frame turning angle
  movement_direction.rotate(turn);//turns the head movement
  head.add(movement_direction);
}


//applies rope physics to spine
void move_spine() {
  spine1 = anchor(spine1, head,   10);
  spine2 = anchor(spine2, spine1, 10);
  spine3 = anchor(spine3, spine2, 15);
  spine4 = anchor(spine4, spine3, 20);
  tail1  = anchor(tail1,  spine4, 20);
  tail2  = anchor(tail2,  tail1,  15);
  tail3  = anchor(tail3,  tail2,  15);
  tail4  = anchor(tail4,  tail3,  15);
}


//input handlers
//multiple verisons used in case player has capslock or doesnt read instructions
void keyPressed() {
  if (key == 'a' || key == 'A' ) {
    left = true;
  }

  if (key == 'd' || key == 'D' ) {
    right = true;
  }

  if (key == ' ' || key == 'w' || key == 'W' ) {
    tongue = true;
  }

  if (key == 's' || key == 'S' ) {
    changecolor = true;
  }
}

void keyReleased() {
  if (key == 'a' || key == 'A' ) {
    left = false;
  }
  if (key == 'd' || key == 'D' ) {
    right = false;
  }
  if (key == ' ' || key == 'w' || key == 'W' ) {
    tongue = false;
  }
  if (key == 's' || key == 'S' ) {
    changecolor = false;
  }
}


//moves the head away from walls if it gets too close
//forcefully steers lizard back on screen if it wanders off
void push_head() {

  //handles right edge of screen
  //turns the head away from edge and towards the screen 
  //uses more force the further away the head is from the play area
  if (head.x > width-border) {
    if (movement_direction.y > 0) {
      movement_direction.rotate((head.x-width+border)/border*push_speed);
    } else {
      movement_direction.rotate((head.x-width+border)/border*push_speed*(-1));
    }
  }

  //handles left edge of screen
  if (head.x < border) {
    if (movement_direction.y > 0) {
      movement_direction.rotate((head.x-border)/border*push_speed);
    } else {
      movement_direction.rotate((head.x-border)/border*push_speed*(-1));
    }
  }

  //handles bottom
  if (head.y > height-border) {
    if (movement_direction.x > 0) {
      movement_direction.rotate((head.y-height+border)/border*push_speed*(-1));
    } else {
      movement_direction.rotate((head.y-height+border)/border*push_speed);
    }
  }

  //handles top
  if (head.y < border) {
    if (movement_direction.x > 0) {
      movement_direction.rotate((head.y-border)/border*push_speed*(-1));
    } else {
      movement_direction.rotate((head.y-border)/border*push_speed);
    }
  }


}


//draws the rounded trapeze that makes up the mainbody
void link(PVector point1, float rad1, PVector point2, float rad2, color col) {
  noStroke();
  ellipse(point1.x, point1.y, rad1*2, rad1*2);
  ellipse(point2.x, point2.y, rad2*2, rad2*2);

  PVector dir = new PVector(point2.x-point1.x, point2.y - point1.y);// calculates the perpendicular of trapeze
  dir.rotate(HALF_PI).normalize(); // makes it paralel to the opposite two sides, is used to calculate vetex positions
  fill(col);

  beginShape();
  vertex(point1.x + dir.x*rad1, point1.y + dir.y*rad1);
  vertex(point2.x + dir.x*rad2, point2.y + dir.y*rad2);
  vertex(point2.x - dir.x*rad2, point2.y - dir.y*rad2);
  vertex(point1.x - dir.x*rad1, point1.y - dir.y*rad1);
  endShape(CLOSE);
}

//something-somethin zelda reference
void shadow_link(PVector p1, float rad1, PVector p2, float rad2, color col) {
  noStroke();
  PVector point1 = new PVector(shadow_offset.x + p1.x, shadow_offset.y + p1.y);//offsets the position where shadow
  PVector point2 = new PVector(shadow_offset.x + p2.x, shadow_offset.y + p2.y);//is drawn by a static ammount
  ellipse(point1.x, point1.y, rad1*2, rad1*2);
  ellipse(point2.x, point2.y, rad2*2, rad2*2);

  PVector dir = new PVector(point2.x-point1.x, point2.y - point1.y);
  dir.rotate(HALF_PI).normalize();
  fill(col);

  beginShape();
  vertex(point1.x + dir.x*rad1, point1.y + dir.y*rad1);
  vertex(point2.x + dir.x*rad2, point2.y + dir.y*rad2);
  vertex(point2.x - dir.x*rad2, point2.y - dir.y*rad2);
  vertex(point1.x - dir.x*rad1, point1.y - dir.y*rad1);
  endShape(CLOSE);
}


// adds meat to the spine using previous trapeze function
void draw_body(color bodycolor) {

  snout = new PVector(movement_direction.x, movement_direction.y);
  snout.normalize().mult(15);//snout is not a bone so it has to be placed based on movement direction

  PVector tongue = new PVector(movement_direction.x, movement_direction.y).normalize().mult(tongue_forward).rotate(sin(millis()/tongue_wave)*tongue_forward*tongue_amp);
  snout.add(head);

  //draws tongue
  strokeWeight(3);
  stroke(tongue_color);
  line(snout.x, snout.y, tongue.x+snout.x, tongue.y+snout.y);

  //connects all points of the body
  fill(bodycolor);
  ellipse(snout.x, snout.y, 2.5, 2.5);
  link(snout, 5, head, 10, bodycolor);
  link(head, 10, spine1, 5, bodycolor);
  link(spine1, 5, spine2, 7.5, bodycolor);
  link(spine2, 7.5, spine3, 10, bodycolor);
  link(spine3, 10, spine4, 7.5, bodycolor);
  link(spine4, 7.5, tail1, 6.25, bodycolor);
  link(tail1, 6.25, tail2, 5, bodycolor);
  link(tail2, 5, tail3, 3.75, bodycolor);
  link(tail3, 3.75, tail4, 2.5, bodycolor);

  //draws the eyes
  PVector eye = new PVector(movement_direction.x, movement_direction.y);
  eye.rotate(HALF_PI).normalize();
  fill(eyecolor);
  ellipse(head.x + eye.x*5, head.y + eye.y*5, 5, 5);
  ellipse(head.x - eye.x*5, head.y - eye.y*5, 5, 5);
}


//draws the shadow of the body using the offset link functions
void draw_body_shadow(color bodycolor) {
  snout = new PVector(movement_direction.x, movement_direction.y);
  snout.normalize().mult(15);
  snout.add(head);
  fill(bodycolor);
  ellipse(snout.x, snout.y, 2.5, 2.5);
  shadow_link(snout, 7, head, 12, bodycolor);
  shadow_link(head, 12, spine1, 7, bodycolor);
  shadow_link(spine1, 7, spine2, 9.5, bodycolor);
  shadow_link(spine2, 9.5, spine3, 12, bodycolor);
  shadow_link(spine3, 12, spine4, 9.5, bodycolor);
  shadow_link(spine4, 9.5, tail1, 8.25, bodycolor);
  shadow_link(tail1, 8.25, tail2, 7, bodycolor);
  shadow_link(tail2, 7, tail3, 5.75, bodycolor);
  shadow_link(tail3, 5.75, tail4, 4.5, bodycolor);
}


//i know its hard to believe but this function draws the legs
void draw_legs(color bodycolor) {

  stroke(bodycolor);
  strokeWeight(7);
  fill(bodycolor);

  //forward left leg
  line(leg_fl_pos.x, leg_fl_pos.y, spine2.x, spine2.y);//leg
  ellipse(leg_fl_pos.x, leg_fl_pos.y, 5, 5);//foot

  //forward right leg
  line(leg_fr_pos.x, leg_fr_pos.y, spine2.x, spine2.y);
  ellipse(leg_fr_pos.x, leg_fr_pos.y, 5, 5);

  //back left leg
  line(leg_bl_pos.x, leg_bl_pos.y, spine4.x, spine4.y);
  ellipse(leg_bl_pos.x, leg_bl_pos.y, 5, 5);

  //back right leg
  line(leg_br_pos.x, leg_br_pos.y, spine4.x, spine4.y);
  ellipse(leg_br_pos.x, leg_br_pos.y, 5, 5);
}


//handles leg logic and movement
void move_legs() {

  //forward left leg

  //legth of this leg right now
  PVector leg = new PVector(spine2.x - leg_fl_pos.x, spine2.y - leg_fl_pos.y);

  //where it should be heading if it's not on the ground
  leg_fl_target = new PVector(spine1.x-spine2.x, spine1.y-spine2.y).normalize().mult(leg_length).rotate(-leg_angle).add(spine2);

  //if foot is too far away and the other legs on this side and pair are down - lift this leg
  //used to make gallpoing and other "nonlizardlike" walks impossible
  if (leg.mag()> leg_length && leg_fl_down && leg_fr_down && leg_bl_down) {
    leg_fl_down = false;
  }

  //if leg is lifted move to new position
  //if less than 1 frame distance away from target - put the leg down on the ground
  if (!leg_fl_down) {
    PVector to_target = new PVector(leg_fl_target.x-leg_fl_pos.x, leg_fl_target.y-leg_fl_pos.y);
    if (to_target.mag() > leg_speed) {
      to_target.normalize().mult(leg_speed); 
      leg_fl_pos.add(to_target);
    } else {
      leg_fl_pos = leg_fl_target;
      leg_fl_down = true;
    }
  }


  //forward right leg, same as before
  leg = new PVector(spine2.x - leg_fr_pos.x, spine2.y - leg_fr_pos.y);
  leg_fr_target = new PVector(spine1.x-spine2.x, spine1.y-spine2.y).normalize().mult(leg_length).rotate(leg_angle).add(spine2);

  if (leg.mag()> leg_length && leg_fr_down && leg_fl_down && leg_br_down) {
    leg_fr_down = false;
  }

  if (!leg_fr_down) {
    PVector to_target = new PVector(leg_fr_target.x-leg_fr_pos.x, leg_fr_target.y-leg_fr_pos.y);
    if (to_target.mag() > leg_speed) {
      to_target.normalize().mult(leg_speed); 
      leg_fr_pos.add(to_target);
    } else {
      leg_fr_pos = leg_fr_target;
      leg_fr_down = true;
    }
  }


  //if one leg in a pair is not on the ground
  //move the joint it is attached to towards the side of the leg that is on the ground
  //always works since only one leg in a pair can be lifted at a time
  //creates swaying and makes it look more lively
  PVector swaydir = new PVector(spine1.x-spine2.x, spine1.y-spine2.y).normalize().rotate(QUARTER_PI);
  if (leg_fl_down && !leg_fr_down) {
    spine2.add(swaydir.mult(-body_sway));
  }
  if (!leg_fl_down && leg_fr_down) {
    spine2.add(swaydir.mult(body_sway));
  }


  //back left leg
  leg = new PVector(spine4.x - leg_bl_pos.x, spine4.y - leg_bl_pos.y);
  leg_bl_target = new PVector(spine3.x-spine4.x, spine3.y-spine4.y).normalize().mult(leg_length).rotate(-leg_angle*1.5).add(spine4);

  if (leg.mag()> leg_length && leg_bl_down && leg_br_down && leg_fl_down) {
    leg_bl_down = false;
  }

  if (!leg_bl_down) {
    PVector to_target = new PVector(leg_bl_target.x-leg_bl_pos.x, leg_bl_target.y-leg_bl_pos.y);
    if (to_target.mag() > leg_speed) {
      to_target.normalize().mult(leg_speed); 
      leg_bl_pos.add(to_target);
    } else {
      leg_bl_pos = leg_bl_target;
      leg_bl_down = true;
    }
  }


  //back right leg
  leg = new PVector(spine4.x - leg_br_pos.x, spine4.y - leg_br_pos.y);
  leg_br_target = new PVector(spine3.x-spine4.x, spine3.y-spine4.y).normalize().mult(leg_length).rotate(leg_angle*1.5).add(spine4);

  if (leg.mag()> leg_length && leg_br_down && leg_bl_down && leg_fr_down) {
    leg_br_down = false;
  }

  if (!leg_br_down) {
    PVector to_target = new PVector(leg_br_target.x-leg_br_pos.x, leg_br_target.y-leg_br_pos.y);
    if (to_target.mag() > leg_speed) {
      to_target.normalize().mult(leg_speed); 
      leg_br_pos.add(to_target);
    } else {
      leg_br_pos = leg_br_target;
      leg_br_down = true;
    }
  }

  swaydir = new PVector(spine3.x-spine4.x, spine3.y-spine4.y).normalize().rotate(QUARTER_PI);
  if (leg_bl_down && !leg_br_down) {
    spine4.add(swaydir.mult(-body_sway));
  }
  if (!leg_bl_down && leg_br_down) {
    spine4.add(swaydir.mult(body_sway));
  }
}


//background and texts
void draw_background() {
  randomSeed(42);
  background(grass);
  fill(grass_shadow);
  textSize(30);
  text("[A][D] steer ", 5, 35);
  text("[W] tongue", 5, 70);
  text("[S] colour", 5, 105);
  
  //draws grid
  for (int x = 0; x < width +5; x += 20){
    for(int y = 0; y < height +5; y += 20){
      strokeWeight(3);
      stroke(grass_shadow);
      point(x,y);
    }
  }

  //once upon a time here was a cool grass thing that spawned it in patches
  //it even waved with time at different speeds
  //it looked like a lot of hungry worms laying on their side
  //rip worm-grass
  
  //now its just a grid
  //grid still looks better than that ugly-ass bezier curve looking thing
}


//identical to draw_legs() except everything is 1px bigger and offset by 3 pixels
void leg_shadow(color shadow_color, float offsetx, float offsety) {
  //forward left leg
  stroke(shadow_color);
  strokeWeight(8);
  line(leg_fl_pos.x+offsetx, leg_fl_pos.y+offsety, spine2.x+offsetx, spine2.y+offsety);
  fill(shadow_color);
  ellipse(leg_fl_pos.x+offsetx, leg_fl_pos.y+offsety, 6, 6);

  //forward right leg
  stroke(shadow_color);
  strokeWeight(8);
  line(leg_fr_pos.x+offsetx, leg_fr_pos.y+offsety, spine2.x+offsetx, spine2.y+offsety);
  fill(shadow_color);
  ellipse(leg_fr_pos.x+offsetx, leg_fr_pos.y+offsety, 6, 6);

  //back left leg
  stroke(shadow_color);
  strokeWeight(8);
  line(leg_bl_pos.x+offsetx, leg_bl_pos.y+offsety, spine4.x+offsetx, spine4.y+offsety);
  fill(shadow_color);
  ellipse(leg_bl_pos.x+offsetx, leg_bl_pos.y+offsety, 6, 6);

  //back right leg
  stroke(shadow_color);
  strokeWeight(8);
  line(leg_br_pos.x+offsetx, leg_br_pos.y+offsety, spine4.x+offsetx, spine4.y+offsety);
  fill(shadow_color);
  ellipse(leg_br_pos.x+offsetx, leg_br_pos.y+offsety, 6, 6);
}


//when key is held down - shifts the hue of the lizard
//using the H in HSB
void change_color() {
  hue += 0.005;
  if (hue > 1) {hue--;}
  
  colorMode(HSB, 1);
  liz_body = color(hue, 0.7, 0.85);
  liz_legs = color(hue, 0.6, 0.68);
}
