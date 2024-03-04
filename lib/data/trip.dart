
class Trip{
   String country ="";
   String city ="";
   String attraction ="";
   String image ="";
   Trip(this.country, this.city,this.attraction,this.image);
   void setTripCountry(String country){
     this.country = country;
   }
   void setTripCity(String city){
     this.city = city;
   }
   void setTripAttraction(String attraction){
     this.attraction = attraction;
   }
   void setTripImage(String image){
     this.image = image;
   }
   String getTripCountry(){
     return country;
   }
   String getTripCity(){
     return city;
   }
   String getTripAttraction(){
     return attraction;
   }
   String getTripImage(){
     return image;
   }
}