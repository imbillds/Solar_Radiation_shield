
ard_tr_x=-26.5;
ard_tr_y=-38.5;
ard_tr_z=1;
dometh=2;
domeht=30;

zipht=1.5;
zipwt=4;

pinht=10;

domedia=10;
riserOD=5;
riseroffset=5;
riserht=27;
longedge=25;
shortedge=13;
toplip=10;

barwh=39;


display_arduino = 0;


include <arduino.scad>

if (display_arduino == 1) {    
    rotate([90,0,0])
        translate([ard_tr_x,ard_tr_y,ard_tr_z-12])
            arduino(UNO);
    
    rotate([90,0,0])
        translate([ard_tr_x,ard_tr_y,ard_tr_z])
            arduino(UNO);
}    



// generate arc points

points = [[0,domeht+toplip], [dometh, domeht+toplip], [dometh, domeht], [domeht, 0], [0,0]];

tpoints = [[0,domeht],  [domeht, 0], [0,0]];

// Uncomment this to display the slot mount for the Arduino
//arduino_slot();

for (b=[-50,-25,0]) {
//for (b=[]) {
    build_dome(b, 1);
}

build_dome(25,2);
build_dome(-75,3);
build_bar();

// printed with 5 perimiters at 0.2 to make sure the bars were not hollow
module build_bar() {
    difference() {
        support_bar(-90);
        translate([0,-114,-130])
            cylinder(80,10,10);
        translate([0,-183,-100])
            cube([80,150,80],center=true);
    }
}

// build a full dome, first param is height
// second param is type, mid = 1 or top = 2 base = 3
module build_dome (b,type) {
    for (z=[0,90,180,270]) {
//    for (z=[0]) {
        rotate([0,0,z]){ 

            edge = longedge;
            otheredge = shortedge;
            if (z==90 || z== 270) {
                edge = shortedge;
                otheredge = longedge;
                if (type == 1) {
                    build_curve(b, edge, otheredge, type, points,z);
                } else {
                    build_curve(b, edge, otheredge, type, tpoints,z);
                }
            } else {
                if (type == 1) {
                    build_curve(b, edge, otheredge, type, points,z);
                } else {
                    build_curve(b, edge, otheredge, type, tpoints,z);
                }
            }
        }
        if (type == 1) {
            // Each dome needs 4 pins for mounting
            rotate([0,0,z+45])
                translate([0,domedia+shortedge,b-riseroffset])
                    pinpeg(h=2*pinht, r=3.5, lh=3, lt=1);
        }
    }

}


module build_curve (b, edge, otheredge, type, points, quadrant) {
    // build curve
    translate([-edge,0,0]) {
        translate([0,-otheredge,0]) {
            difference() {
                difference() {
                    if (type != 3) {
                        rotate_extrude($fn=75,convexity = 10)
                            translate([domedia,b,0])
                                difference() {
                                    polygon(points);
                                    translate([-dometh,-dometh])
                                        polygon(points);
                                }
                    } else if (type == 3){
                        supwh=14;
                        supth=4;
                        suplip=14;
                        supoff=3.5;
                        // Build base cross bars
                        translate([-domeht+5,-domeht+5,b+1]){
                            //rotate([0,0,45])
                            difference() {
                                cube([domeht*2+(edge-5)*2,supwh,supth]);
                                // add holes for retaining pins
                                translate([domeht+edge-5-8,7,0])
                                    cylinder(5,2,2);
                                translate([domeht+edge-5+8,7,0])
                                    cylinder(5,2,2);
                                translate([domeht+edge-5,7,0])
                                    cylinder(5,2,2);
                            }
                            translate([6,6,0])
                                cylinder(supth,8,8);
                        }
                        //build base support hooks
                        if (quadrant==0 || quadrant== 180) {
                            //right hook
                            translate([0,-domeht+supth+1,b-supth])
                                cube([supth,supwh,supth+1]);
                            translate([0,-domeht+supth+1,b-supth*2])
                                cube([suplip,supwh,supth]);
                            translate([0,-domeht+supth+1,b-supth-4])
                                rotate([0,-57,0])
                                    cube([5,supwh,16]);
                            
                            // left hook
                            translate([barwh+supoff*2,-domeht+supth+1,b-supth])
                                cube([supth,supwh,supth+1]);
                            translate([barwh-suplip+supth*2+3,-domeht+supth+1,b-supth*2])
                                cube([suplip,supwh,supth]);
                            translate([barwh+8,-domeht+supth+1,b-supth+0.15])
                                rotate([0,57,0])
                                    cube([5,supwh,16]);
                        }                        
                    }
                    //build standoff hole
                    if ((type == 1) || (type == 3)) {
                        for (c=[225]) {
                            rotate([0,0,c]){ 
                                translate([domedia+16,0,b])
                                    linear_extrude(height=50)
                                        circle(riserOD);
                            }
                        }
                        // put hole at other corner to fix overlap on type 3
                        // should be fine for type1
                        for (c=[225]) {
                            translate([domedia*2+edge*2+16,0,0])
                            rotate([0,0,c]){ 
                                translate([domedia+16,0,b])
                                    linear_extrude(height=50)
                                        circle(riserOD);
                            }
                        }
                    }
                    
                    // don't chop the center up for the base??? or should we
                    if (type != 3) {
                            
                        // delete half of the circle
                        translate([100,0,b])
                            cube(200, center=true);
                        // delete quarter of the circle
                        translate([0,100,b])
                            cube(200, center=true);
                    }
                }
            }

            //build standoff
                for (c=[225]) {
                    rotate([0,0,c]) {
                        if (type == 1) {

                        translate([domedia+16,0,b-riseroffset])
                            difference() {
                                linear_extrude(height=riserht)
                                    difference(){
                                        circle($fn=25,riserOD);
                                        circle(3);
                                    }
                                    pinhole(h=pinht, r=3.5, lh=3, lt=1, t=0.3, tight=false);
                                    translate([0,0,riserht])
                                        rotate([180,0,0])
                                            pinhole(h=pinht, r=3.5, lh=3, lt=1, t=0.3, tight=false);

                            }
                        //build standoff for top
                        } else if (type == 2)  {
                            translate([domedia+16,0,b-riseroffset])
                                difference() {
                                    cylinder(20,riserOD,riserOD);
                                    translate([5,-7,10])
                                        rotate([5,-45,0])
                                            cube(15);
                                    pinhole(h=pinht, r=3.5, lh=3, lt=1, t=0.3, tight=false);
                                }
                        //build standoff for base
                        } else if (type == 3) {
                        translate([domedia+16,0,b-riseroffset])
                            difference() {
                                linear_extrude(height=pinht)
                                    difference(){
                                        circle($fn=25,riserOD);
                                        circle(3);
                                    }
                                    pinhole(h=pinht, r=3.5, lh=3, lt=1, t=0.3, tight=false);
                                    translate([0,0,pinht])
                                        rotate([180,0,0])
                                            pinhole(h=pinht, r=3.5, lh=3, lt=1, t=0.3, tight=false);

                            }
                                
                                
                                
                        }
                    }        
            }
        }
                                        
        if (type != 3) {
            // build long edge
            rotate([90,0,270])
                translate([domedia+otheredge,b,-edge])
                    linear_extrude(height=edge)
                        difference() {
                            polygon(points);
                            translate([-dometh,-dometh])
                                polygon(points);
                        }
            // build short edge
            rotate([90,0,180])
    //                    translate([domedia+longedge,b,0])
                translate([domedia,b,-otheredge])
                    linear_extrude(height=otheredge)
                        difference() {
                            polygon(points);
                            translate([-dometh,-dometh])
                                polygon(points);
                        }
        }
                
        // card support
        if (type == 1) {
            tnu1=domedia-3;
            tnu2=5;
            tnu3=28;
            for (tnu2=[5,-5]){
                translate([-tnu1,tnu2,b+tnu3])
                    difference() {
                        linear_extrude(height=toplip+dometh)
                            square([7,5],center=true);
                        // zip tie slot
                        // horizontal slots
                        ztoff=2.5;
                        for (h=[ztoff-(zipht),toplip+dometh-ztoff]){
                            translate([zipwt*.05,0,h])
                                linear_extrude(height=zipht)
                                    square([zipwt,7],center=true);
                        }
                        // vertical slots
                        for (j=[1.8,-1.3]){
                            translate([j,0,((toplip+dometh)/2)-zipht])
                                linear_extrude(height=zipwt)
                                    square([zipht,7],center=true);
                        }
                    }
            }
        }
        
        // build top if type2
        if (type == 2) {
            // put some funny numbers in to make it line up
            translate([0,0,b+domeht-2.7]){
                cube([edge+22,otheredge+10,2.7]);
                    translate([-1,otheredge+1,0])
                    cylinder(2.7,domedia,domedia);
            }
        }        
    }
}
module support_bar (elevation) {
    translate([0,-60,elevation]){
        for (d=[0,shortedge*2+domedia*2+16]){
            translate([0,d+29,0]) {
                difference() {
                    //cube([barwh,200,4], center=true);
                    cube([barwh+3,14,4], center=true);
                    translate([0,0,-2])
                        cylinder(50,2,2);
                    translate([8,0,-2])
                        cylinder(50,2,2);
                    translate([-8,0,-2])
                        cylinder(50,2,2);
                    
                }
            }
        }
        for (d=[-13,13]) {
            translate([d,shortedge*2+domedia*2+14,0]){
                rotate([0,0,90]){
                    cube([barwh+9,16,4], center=true);
                }
            }
        }
        for (e=[-17,-6,6,17])
        translate([e,-65,0])
            rotate([90,0,0])
                cylinder(180,2,2, center=true);

//        for (e=[-6,6]){
        for (e=[-17,-6,6,17]){
            if (abs(e) > 7) {
                translate([e,2,-19])
                    rotate([90,0,0])
                        cylinder(180,2,2);
            } else {
                translate([e,75,-19])
                    rotate([90,0,0])
                        cylinder(180,2,2);
            }
            
            if (abs(e) < 7) {
                for (f=[2,27,52,77]){
                    rotate([-45,0,0])
                        translate([e,68-f,54-f])
                            cylinder(28,2,2, center=true);
                }
                for (f=[-47,-22,3,28]){
                    rotate([45,0,0]){
                        g=-79;
                        translate([e,f-68-g,0-f+54+g])
                            cylinder(28,2,2, center=true);
                    }
                }
            } else {
                for (f=[52,77]){
                    rotate([-45,0,0])
                        translate([e,68-f,54-f])
                            cylinder(28,2,2, center=true);
                }
                for (f=[-47,-22]){
                    rotate([45,0,0]){
                        g=-79;
                        translate([e,f-68-g,0-f+54+g])
                            cylinder(28,2,2, center=true);
                    }
                }
                
            }
            
        }
        for (g=[-36,0]) 
            translate([-17,-14+g,0])
                rotate([0,90,0])
                    cylinder(35,2,2);
        for (g=[-36,-18,18]) 
            translate([-17,-14+g,-19])
                rotate([0,90,0])
                    cylinder(35,2,2);
        for (g=[36+18,36+36+18])
            translate([-8,-14+g,-19])
                rotate([0,90,0])
                    cylinder(16,2,2);

// add support by semicircle
            translate([-17,-39,-19])
                rotate([0,90,0])
                    cylinder(35,2,2);
            translate([-17,-39,-0])
                rotate([0,90,0])
                    cylinder(35,2,2);
            translate([-16,-45,-21])
                rotate([0,0,0])
                    cylinder(23,4,4);
            translate([16,-45,-21])
                rotate([0,0,0])
                    cylinder(23,4,4);

//diagional support
        for (g=[-32,-14,4]){
            translate([-17,g,-19])
                rotate([0,61,0])
                    cylinder(40,2,2);
            translate([17,g,-19])
                rotate([0,-61,0])
                    cylinder(40,2,2);
        }
        
            translate([17,5,-19])
                rotate([-90,0,9])
                    cylinder(70,2,2);
            translate([-17,5,-19])
                rotate([-90,0,-9])
                    cylinder(70,2,2);
        
        
        //translate([-20,-52,-39])
        //cube([40,10,60]);
        translate([0,-57,-39])
            cylinder(60,18,18);

//        translate([0,0,-7])
//            cube([2,200,15],center=true);
    }
}
module arduino_slot () {
    //arduino slot holder
    rotate([90,0,0])
        translate([ard_tr_x,ard_tr_y,ard_tr_z-13.3])
            difference(){
                // make large block
                boardShape(UNO, offset=5, height=4.5);
                // cut off top and bottom, leave a lip (offset)
                boardShape(UNO, offset=-1, height=6);
                // cut notch
                translate([0,0,1.2])
                    boardShape(UNO, offset=1, height=2);
                // cut notch through top
                translate([0,10,1.2])
                    boardShape(UNO, offset=1, height=2);
                // cut top and bottom through top
                translate([0,10,0])
                    boardShape(UNO, offset=-1, height=6);
                // clear space for USB connection
                translate([8,-7,2.5])
                    cube(13);
                translate([8,-15.5,0.5])
                    cube(13);
                // clear space for power connection
                translate([40,-7,2.5])
                    cube(10);
                // zip tie slot
                ztoff=12;
                for (r=[-3.1,56.5]){
                    for (h=[ 0:6:66]){
                        translate([r,h,0])
                            linear_extrude(height=20)
                                square([zipht,zipwt],center=true);
                    }
                }
                // cut the jaged part from the top
                translate([50,69.836,0])
                    cube(10);
            }
};

