package com.spareshub.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "products")
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    private String name;
    @Column(name = "part_number")
    private String partNumber;
    private Double mrp;
    @Column(name = "selling_price")
    private Double sellingPrice;
    @Column(name = "wholesaler_price")
    private Double wholesalerPrice;
    @Column(name = "retailer_price")
    private Double retailerPrice;
    @Column(name = "mechanic_price")
    private Double mechanicPrice;
    private Integer stock;
    @Column(name = "wholesaler_id")
    private Integer wholesalerId;
    @Column(name = "image_path")
    private String imagePath;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getPartNumber() { return partNumber; }
    public void setPartNumber(String partNumber) { this.partNumber = partNumber; }
    public Double getMrp() { return mrp; }
    public void setMrp(Double mrp) { this.mrp = mrp; }
    public Double getSellingPrice() { return sellingPrice; }
    public void setSellingPrice(Double sellingPrice) { this.sellingPrice = sellingPrice; }
    public Double getWholesalerPrice() { return wholesalerPrice; }
    public void setWholesalerPrice(Double wholesalerPrice) { this.wholesalerPrice = wholesalerPrice; }
    public Double getRetailerPrice() { return retailerPrice; }
    public void setRetailerPrice(Double retailerPrice) { this.retailerPrice = retailerPrice; }
    public Double getMechanicPrice() { return mechanicPrice; }
    public void setMechanicPrice(Double mechanicPrice) { this.mechanicPrice = mechanicPrice; }
    public Integer getStock() { return stock; }
    public void setStock(Integer stock) { this.stock = stock; }
    public Integer getWholesalerId() { return wholesalerId; }
    public void setWholesalerId(Integer wholesalerId) { this.wholesalerId = wholesalerId; }
    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }
}
