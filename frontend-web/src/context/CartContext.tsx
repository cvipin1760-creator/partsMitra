import React, { createContext, useContext, useEffect, useMemo, useState } from 'react';

type CartItem = {
  productId: number;
  name: string;
  price: number;
  partNumber?: string;
  quantity: number;
  wholesalerId?: number;
};

type CartContextValue = {
  items: CartItem[];
  addItem: (item: Omit<CartItem, 'quantity'>, qty?: number) => void;
  removeItem: (productId: number) => void;
  updateQty: (productId: number, qty: number) => void;
  clear: () => void;
  count: number;
  total: number;
};

const CartContext = createContext<CartContextValue | undefined>(undefined);

export const CartProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [items, setItems] = useState<CartItem[]>(() => {
    try {
      const raw = localStorage.getItem('cart');
      return raw ? JSON.parse(raw) : [];
    } catch {
      return [];
    }
  });

  useEffect(() => {
    try {
      localStorage.setItem('cart', JSON.stringify(items));
    } catch {}
  }, [items]);

  const addItem = (item: Omit<CartItem, 'quantity'>, qty: number = 1) => {
    setItems((prev) => {
      const idx = prev.findIndex((p) => p.productId === item.productId);
      if (idx >= 0) {
        const next = [...prev];
        next[idx] = { ...next[idx], quantity: next[idx].quantity + qty };
        return next;
      }
      return [...prev, { ...item, quantity: qty }];
    });
  };

  const removeItem = (productId: number) => {
    setItems((prev) => prev.filter((p) => p.productId !== productId));
  };

  const updateQty = (productId: number, qty: number) => {
    setItems((prev) =>
      prev.map((p) => (p.productId === productId ? { ...p, quantity: Math.max(1, qty) } : p)),
    );
  };

  const clear = () => setItems([]);

  const count = useMemo(() => items.reduce((acc, i) => acc + i.quantity, 0), [items]);
  const total = useMemo(() => items.reduce((acc, i) => acc + i.price * i.quantity, 0), [items]);

  const value: CartContextValue = {
    items,
    addItem,
    removeItem,
    updateQty,
    clear,
    count,
    total,
  };

  return <CartContext.Provider value={value}>{children}</CartContext.Provider>;
};

export const useCart = () => {
  const ctx = useContext(CartContext);
  if (!ctx) throw new Error('useCart must be used within CartProvider');
  return ctx;
};
