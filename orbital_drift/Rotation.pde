
class Rotation {

  Rotation(float initX, float initY, float initZ) {
    x = initX;
    y = initY;
    z = initZ;
  }

  void increment(Rotation increment) {
    x = incremented(x, increment.x);
    y = incremented(y, increment.y);
    z = incremented(z, increment.z);
  }

  float incremented(float angle, float increment) {
    float newAngle = angle + increment;
    if (newAngle > TWO_PI) newAngle -= TWO_PI;
    else if (newAngle < TWO_PI) newAngle += TWO_PI;
    return newAngle;
  }
  
  Rotation scaled(float scale) {
    return new Rotation(x / scale, y / scale, z / scale);
  }

  float x;
  float y;
  float z;
}