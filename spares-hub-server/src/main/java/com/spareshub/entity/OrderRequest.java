package com.spareshub.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "order_requests")
public class OrderRequest {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    @Column(name = "customer_id")
    private Integer customerId;
    @Column(name = "customer_name")
    private String customerName;
    private String text;
    @Column(name = "photo_path")
    private String photoPath;
    private String status;
    @Column(name = "created_at")
    private String createdAt;
    @Column(name = "assigned_staff_id")
    private Integer assignedStaffId;
    @Column(name = "assigned_staff_name")
    private String assignedStaffName;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public Integer getCustomerId() { return customerId; }
    public void setCustomerId(Integer customerId) { this.customerId = customerId; }
    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }
    public String getText() { return text; }
    public void setText(String text) { this.text = text; }
    public String getPhotoPath() { return photoPath; }
    public void setPhotoPath(String photoPath) { this.photoPath = photoPath; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
    public Integer getAssignedStaffId() { return assignedStaffId; }
    public void setAssignedStaffId(Integer assignedStaffId) { this.assignedStaffId = assignedStaffId; }
    public String getAssignedStaffName() { return assignedStaffName; }
    public void setAssignedStaffName(String assignedStaffName) { this.assignedStaffName = assignedStaffName; }
}
