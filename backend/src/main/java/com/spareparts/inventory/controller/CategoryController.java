package com.spareparts.inventory.controller;

import com.spareparts.inventory.dto.CategorySimpleDto;
import com.spareparts.inventory.entity.Category;
import com.spareparts.inventory.dto.ProductDto;
import com.spareparts.inventory.entity.Product;
import com.spareparts.inventory.repository.CategoryRepository;
import com.spareparts.inventory.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/categories")
public class CategoryController {
    @Autowired
    private CategoryRepository categoryRepository;
    @Autowired
    private ProductRepository productRepository;

    private CategorySimpleDto convertToDto(Category c) {
        if (c == null) return null;
        CategorySimpleDto dto = new CategorySimpleDto();
        dto.setId(c.getId());
        dto.setName(c.getName());
        dto.setDescription(c.getDescription());
        dto.setImagePath(c.getImagePath());
        dto.setImageLink(c.getImageLink());
        if (c.getParent() != null) {
            dto.setParentId(c.getParent().getId());
            dto.setParent(new CategorySimpleDto.ParentCategoryDto(c.getParent().getId(), c.getParent().getName()));
        }
        if (c.getSubCategories() != null && !c.getSubCategories().isEmpty()) {
            dto.setSubCategories(c.getSubCategories().stream()
                    .map(sub -> {
                        CategorySimpleDto subDto = new CategorySimpleDto();
                        subDto.setId(sub.getId());
                        subDto.setName(sub.getName());
                        subDto.setDescription(sub.getDescription());
                        subDto.setImagePath(sub.getImagePath());
                        subDto.setImageLink(sub.getImageLink());
                        subDto.setParentId(c.getId());
                        subDto.setParent(new CategorySimpleDto.ParentCategoryDto(c.getId(), c.getName()));
                        return subDto;
                    })
                    .collect(Collectors.toList()));
        } else {
            dto.setSubCategories(new ArrayList<>());
        }
        return dto;
    }

    @GetMapping
    public ResponseEntity<List<CategorySimpleDto>> list(@RequestParam(value = "rootsOnly", required = false, defaultValue = "false") boolean rootsOnly) {
        try {
            List<Category> categories;
            if (rootsOnly) {
                categories = categoryRepository.findByParentIsNullAndDeletedFalse();
            } else {
                categories = categoryRepository.findByDeletedFalse();
            }
            return ResponseEntity.ok(categories.stream().map(this::convertToDto).collect(Collectors.toList()));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().build();
        }
    }

    @GetMapping("/{id}/subcategories")
    public ResponseEntity<List<CategorySimpleDto>> subcategories(@PathVariable Long id) {
        return ResponseEntity.ok(categoryRepository.findByParent_IdAndDeletedFalse(id).stream()
                .map(this::convertToDto)
                .collect(Collectors.toList()));
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN') or hasRole('SUPER_MANAGER')")
    public ResponseEntity<CategorySimpleDto> create(@RequestBody Map<String, Object> req) {
        String name = (String) req.getOrDefault("name", "");
        String description = (String) req.getOrDefault("description", "");
        if (name.trim().isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        Category c = new Category();
        c.setName(name);
        c.setDescription(description);
        c.setImagePath((String) req.getOrDefault("imagePath", ""));
        c.setImageLink((String) req.getOrDefault("imageLink", ""));

        if (req.containsKey("parentId") && req.get("parentId") != null) {
            Long parentId = Long.valueOf(req.get("parentId").toString());
            categoryRepository.findById(parentId).ifPresent(c::setParent);
        }

        return ResponseEntity.ok(convertToDto(categoryRepository.save(c)));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SUPER_MANAGER')")
    public ResponseEntity<CategorySimpleDto> update(@PathVariable Long id, @RequestBody Map<String, Object> req) {
        Category c = categoryRepository.findById(id).orElse(null);
        if (c == null) return ResponseEntity.notFound().build();
        
        if (req.containsKey("name")) c.setName((String) req.get("name"));
        if (req.containsKey("description")) c.setDescription((String) req.get("description"));
        if (req.containsKey("imagePath")) c.setImagePath((String) req.get("imagePath"));
        if (req.containsKey("imageLink")) c.setImageLink((String) req.get("imageLink"));
        
        if (req.containsKey("parentId")) {
            if (req.get("parentId") == null) {
                c.setParent(null);
            } else {
                Long parentId = Long.valueOf(req.get("parentId").toString());
                if (!parentId.equals(id)) { // Prevent self-referencing
                    categoryRepository.findById(parentId).ifPresent(c::setParent);
                }
            }
        }
        
        return ResponseEntity.ok(convertToDto(categoryRepository.save(c)));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SUPER_MANAGER')")
    public ResponseEntity<?> delete(@PathVariable Long id) {
        if (!categoryRepository.existsById(id)) return ResponseEntity.notFound().build();
        categoryRepository.deleteById(id);
        return ResponseEntity.ok().build();
    }

    @Autowired
    private com.spareparts.inventory.service.ProductService productService;

    @GetMapping("/{id}/products")
    public ResponseEntity<List<ProductDto>> productsByCategory(@PathVariable Long id) {
        return ResponseEntity.ok(productService.getProductsByCategory(id));
    }
}
