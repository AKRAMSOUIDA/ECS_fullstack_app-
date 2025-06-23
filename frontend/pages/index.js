import { useState, useEffect } from 'react';

export default function Home() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [newUser, setNewUser] = useState({ name: '', email: '' });

  const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001';

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      const response = await fetch(`${API_URL}/api/users`);
      const data = await response.json();
      setUsers(data);
    } catch (error) {
      console.error('Error fetching users:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const response = await fetch(`${API_URL}/api/users`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(newUser),
      });
      const user = await response.json();
      setUsers([...users, user]);
      setNewUser({ name: '', email: '' });
    } catch (error) {
      console.error('Error creating user:', error);
    }
  };

  return (
    <div style={{ padding: '20px', fontFamily: 'Arial, sans-serif' }}>
      <h1>Fullstack App - Users</h1>
      
      <form onSubmit={handleSubmit} style={{ marginBottom: '20px' }}>
        <div style={{ marginBottom: '10px' }}>
          <input
            type="text"
            placeholder="Name"
            value={newUser.name}
            onChange={(e) => setNewUser({ ...newUser, name: e.target.value })}
            required
            style={{ padding: '8px', marginRight: '10px' }}
          />
          <input
            type="email"
            placeholder="Email"
            value={newUser.email}
            onChange={(e) => setNewUser({ ...newUser, email: e.target.value })}
            required
            style={{ padding: '8px', marginRight: '10px' }}
          />
          <button type="submit" style={{ padding: '8px 16px' }}>
            Add User
          </button>
        </div>
      </form>

      {loading ? (
        <p>Loading users...</p>
      ) : (
        <div>
          <h2>Users List</h2>
          {users.length === 0 ? (
            <p>No users found</p>
          ) : (
            <ul>
              {users.map((user) => (
                <li key={user.id} style={{ marginBottom: '10px' }}>
                  <strong>{user.name}</strong> - {user.email}
                </li>
              ))}
            </ul>
          )}
        </div>
      )}
    </div>
  );
}
