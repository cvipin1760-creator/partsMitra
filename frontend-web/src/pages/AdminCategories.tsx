import React, { useEffect, useState } from 'react';
import api from '../services/api';

type Category = { id: number; name: string; description?: string; imagePath?: string; imageLink?: string };

const AdminCategories: React.FC = () => {
  const [categories, setCategories] = useState<Category[]>([]);
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [imagePath, setImagePath] = useState('');
  const [imageLink, setImageLink] = useState('');
  const [editing, setEditing] = useState<Category | null>(null);
  const [assignProductId, setAssignProductId] = useState('');
  const [assignCategoryId, setAssignCategoryId] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const load = async () => {
    setLoading(true);
    setError('');
    try {
      const res = await api.get('/categories');
      setCategories(res.data || []);
    } catch (e: any) {
      setError('Failed to load categories');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(); }, []);

  const submit = async () => {
    if (!name.trim()) return;
    setLoading(true);
    setError('');
    try {
      if (editing) {
        await api.put(`/categories/${editing.id}`, { name, description, imagePath, imageLink });
      } else {
        await api.post('/categories', { name, description, imagePath, imageLink });
      }
      setName('');
      setDescription('');
      setImagePath('');
      setImageLink('');
      setEditing(null);
      await load();
    } catch {
      setError('Save failed');
    } finally {
      setLoading(false);
    }
  };

  const del = async (id: number) => {
    if (!confirm('Delete this category?')) return;
    setLoading(true);
    setError('');
    try {
      await api.delete(`/categories/${id}`);
      await load();
    } catch {
      setError('Delete failed');
    } finally {
      setLoading(false);
    }
  };

  const assign = async () => {
    const pid = Number(assignProductId);
    const cid = Number(assignCategoryId);
    if (!pid || !cid) return;
    setLoading(true);
    setError('');
    try {
      // Fetch product, then update with categoryId
      const prod = await api.get(`/products`);
      const p = (prod.data || []).find((it: any) => it.id === pid);
      if (!p) throw new Error('Product not found');
      const body = { ...p, categoryId: cid };
      await api.put(`/products/${pid}`, body);
      setAssignProductId('');
      setAssignCategoryId('');
      alert('Category assigned to product');
    } catch {
      setError('Assign failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-gray-900">Categories</h1>
      </div>
      {error && <div className="p-3 rounded bg-red-50 text-red-700">{error}</div>}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div className="bg-white p-4 rounded-xl border border-gray-200">
          <h2 className="font-bold mb-3">{editing ? 'Edit Category' : 'New Category'}</h2>
          <div className="space-y-3">
            <input value={name} onChange={(e) => setName(e.target.value)} placeholder="Name" className="w-full border rounded px-3 py-2" />
            <input value={description} onChange={(e) => setDescription(e.target.value)} placeholder="Description" className="w-full border rounded px-3 py-2" />
            <input value={imagePath} onChange={(e) => setImagePath(e.target.value)} placeholder="Image Path (Upload Result)" className="w-full border rounded px-3 py-2" />
            <input value={imageLink} onChange={(e) => setImageLink(e.target.value)} placeholder="Image Link (External URL)" className="w-full border rounded px-3 py-2" />
            <div className="flex gap-2">
              <button onClick={submit} disabled={loading || !name.trim()} className="px-4 py-2 rounded bg-primary-600 text-white hover:bg-primary-700">Save</button>
              {editing && (
                <button onClick={() => { setEditing(null); setName(''); setDescription(''); setImagePath(''); setImageLink(''); }} className="px-4 py-2 rounded bg-gray-100">Cancel</button>
              )}
            </div>
          </div>
        </div>
        <div className="bg-white p-4 rounded-xl border border-gray-200">
          <h2 className="font-bold mb-3">Assign Category to Product</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
            <input value={assignProductId} onChange={(e) => setAssignProductId(e.target.value)} placeholder="Product ID" className="border rounded px-3 py-2" />
            <select value={assignCategoryId} onChange={(e) => setAssignCategoryId(e.target.value)} className="border rounded px-3 py-2">
              <option value="">Select Category</option>
              {categories.map(c => <option key={c.id} value={c.id}>{c.name}</option>)}
            </select>
          </div>
          <div className="mt-3">
            <button onClick={assign} disabled={loading || !assignProductId || !assignCategoryId} className="px-4 py-2 rounded bg-green-600 text-white hover:bg-green-700">Assign</button>
          </div>
        </div>
      </div>

      <div className="bg-white p-4 rounded-xl border border-gray-200">
        <h2 className="font-bold mb-3">All Categories</h2>
        {loading ? (
          <div>Loading...</div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
            {categories.map(c => (
              <div key={c.id} className="p-3 rounded border border-gray-200 flex items-center justify-between">
                <div>
                  <div className="font-bold">{c.name}</div>
                  {c.description && <div className="text-sm text-gray-500">{c.description}</div>}
                </div>
                <div className="flex gap-2">
                  <button onClick={() => { setEditing(c); setName(c.name); setDescription(c.description || ''); setImagePath(c.imagePath || ''); setImageLink(c.imageLink || ''); }} className="px-3 py-1 rounded bg-gray-100">Edit</button>
                  <button onClick={() => del(c.id)} className="px-3 py-1 rounded bg-red-600 text-white">Delete</button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default AdminCategories;
