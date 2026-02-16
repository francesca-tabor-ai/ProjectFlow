# Real-time Collaboration Guide

Complete guide to real-time functionality in ProjectFlow using Supabase Realtime.

## Table of Contents

1. [Overview](#1-overview)
2. [Basic Subscriptions](#2-basic-subscriptions)
3. [Subscribing to Table Changes](#3-subscribing-to-table-changes)
4. [Live Cursor Indicators](#4-live-cursor-indicators)
5. [Simultaneous Editing](#5-simultaneous-editing)
6. [Presence System](#6-presence-system)
7. [Best Practices](#7-best-practices)

---

## 1. Overview

### What is Supabase Realtime?

Supabase provides real-time capabilities out-of-the-box using WebSockets:

```
Database Change → Supabase → WebSocket → Client → UI Update
```

### Key Features

- ✅ **Database Changes** - Subscribe to INSERT, UPDATE, DELETE
- ✅ **Presence** - Track who's online and where
- ✅ **Broadcast** - Send custom messages between clients
- ✅ **Channels** - Organize subscriptions by topic

### Use Cases in ProjectFlow

1. **Live Cursor Indicators** - See where other users are working
2. **Simultaneous Editing** - Multiple users editing same sheet
3. **Live Updates** - See changes as they happen
4. **Presence** - See who's viewing/editing

---

## 2. Basic Subscriptions

### Subscribe to Table Changes

```typescript
import { getSupabaseClient } from './services/supabaseService';

const supabase = getSupabaseClient();

// Subscribe to row changes
const subscription = supabase
  .channel('rows-changes')
  .on(
    'postgres_changes',
    {
      event: '*',  // INSERT, UPDATE, DELETE
      schema: 'public',
      table: 'rows',
      filter: `sheet_id=eq.${sheetId}`
    },
    (payload) => {
      console.log('Change received!', payload);
      
      switch (payload.eventType) {
        case 'INSERT':
          console.log('New row:', payload.new);
          // Add row to UI
          break;
        case 'UPDATE':
          console.log('Updated row:', payload.new);
          // Update row in UI
          break;
        case 'DELETE':
          console.log('Deleted row:', payload.old);
          // Remove row from UI
          break;
      }
    }
  )
  .subscribe();

// Cleanup when component unmounts
return () => {
  subscription.unsubscribe();
};
```

### Subscribe to Specific Events

```typescript
// Only INSERT events
const subscription = supabase
  .channel('new-rows')
  .on(
    'postgres_changes',
    {
      event: 'INSERT',
      schema: 'public',
      table: 'rows',
      filter: `sheet_id=eq.${sheetId}`
    },
    (payload) => {
      console.log('New row created:', payload.new);
    }
  )
  .subscribe();

// Only UPDATE events
const subscription = supabase
  .channel('row-updates')
  .on(
    'postgres_changes',
    {
      event: 'UPDATE',
      schema: 'public',
      table: 'rows',
      filter: `sheet_id=eq.${sheetId}`
    },
    (payload) => {
      console.log('Row updated:', payload.new);
    }
  )
  .subscribe();
```

---

## 3. Subscribing to Table Changes

### Rows Table (Our Implementation)

**Note**: The PRD example uses `cells` table, but we use `rows` table with JSONB:

```typescript
// Subscribe to row changes
const subscription = supabase
  .channel('rows-changes')
  .on(
    'postgres_changes',
    {
      event: '*',
      schema: 'public',
      table: 'rows',
      filter: `sheet_id=eq.${sheetId}`
    },
    (payload) => {
      console.log('Change received!', payload);
      
      // Update UI with real-time changes
      if (payload.eventType === 'UPDATE') {
        updateRowInUI(payload.new);
      }
    }
  )
  .subscribe();

// Cleanup
return () => {
  subscription.unsubscribe();
};
```

### Projects Table

```typescript
// Subscribe to project changes
const subscription = supabase
  .channel('project-changes')
  .on(
    'postgres_changes',
    {
      event: '*',
      schema: 'public',
      table: 'projects',
      filter: `workspace_id=eq.${workspaceId}`
    },
    (payload) => {
      console.log('Project change:', payload);
    }
  )
  .subscribe();
```

### Sheets Table

```typescript
// Subscribe to sheet changes
const subscription = supabase
  .channel('sheet-changes')
  .on(
    'postgres_changes',
    {
      event: '*',
      schema: 'public',
      table: 'sheets',
      filter: `project_id=eq.${projectId}`
    },
    (payload) => {
      console.log('Sheet change:', payload);
    }
  )
  .subscribe();
```

### Columns Table

```typescript
// Subscribe to column changes
const subscription = supabase
  .channel('column-changes')
  .on(
    'postgres_changes',
    {
      event: '*',
      schema: 'public',
      table: 'columns',
      filter: `sheet_id=eq.${sheetId}`
    },
    (payload) => {
      console.log('Column change:', payload);
    }
  )
  .subscribe();
```

---

## 4. Live Cursor Indicators

### Track User Cursor Position

```typescript
import { useEffect, useState } from 'react';
import { getSupabaseClient } from './services/supabaseService';

function SheetEditor({ sheetId }) {
  const supabase = getSupabaseClient();
  const [cursors, setCursors] = useState({});
  const [myCursor, setMyCursor] = useState({ row: 0, col: 0 });

  useEffect(() => {
    const { data: { user } } = await supabase.auth.getUser();
    const channel = supabase.channel(`cursors-${sheetId}`);

    // Track my cursor position
    const updateMyCursor = (row, col) => {
      setMyCursor({ row, col });
      
      // Broadcast cursor position
      channel.send({
        type: 'broadcast',
        event: 'cursor',
        payload: {
          userId: user.id,
          userName: user.user_metadata.name || user.email,
          row,
          col,
          timestamp: Date.now()
        }
      });
    };

    // Listen for other users' cursors
    channel
      .on('broadcast', { event: 'cursor' }, (payload) => {
        setCursors(prev => ({
          ...prev,
          [payload.userId]: {
            row: payload.row,
            col: payload.col,
            userName: payload.userName,
            timestamp: payload.timestamp
          }
        }));
      })
      .subscribe();

    // Cleanup old cursors (remove if inactive for 5 seconds)
    const cleanupInterval = setInterval(() => {
      const now = Date.now();
      setCursors(prev => {
        const filtered = {};
        Object.entries(prev).forEach(([userId, cursor]) => {
          if (now - cursor.timestamp < 5000) {
            filtered[userId] = cursor;
          }
        });
        return filtered;
      });
    }, 1000);

    return () => {
      channel.unsubscribe();
      clearInterval(cleanupInterval);
    };
  }, [sheetId]);

  return (
    <div>
      {/* Render cursors */}
      {Object.entries(cursors).map(([userId, cursor]) => (
        <div
          key={userId}
          className="cursor-indicator"
          style={{
            position: 'absolute',
            top: cursor.row * 30,
            left: cursor.col * 150
          }}
        >
          {cursor.userName}
        </div>
      ))}
    </div>
  );
}
```

### Presence-Based Cursor Tracking

```typescript
function usePresence(sheetId: string) {
  const supabase = getSupabaseClient();
  const [presences, setPresences] = useState({});

  useEffect(() => {
    const { data: { user } } = await supabase.auth.getUser();
    const channel = supabase.channel(`presence-${sheetId}`);

    // Track presence
    channel
      .on('presence', { event: 'sync' }, () => {
        const state = channel.presenceState();
        setPresences(state);
      })
      .on('presence', { event: 'join' }, ({ key, newPresences }) => {
        console.log('User joined:', newPresences);
      })
      .on('presence', { event: 'leave' }, ({ key, leftPresences }) => {
        console.log('User left:', leftPresences);
      })
      .subscribe(async (status) => {
        if (status === 'SUBSCRIBED') {
          // Set initial presence
          await channel.track({
            userId: user.id,
            userName: user.user_metadata.name || user.email,
            cursor: { row: 0, col: 0 },
            online_at: new Date().toISOString()
          });
        }
      });

    // Update cursor position
    const updateCursor = (row: number, col: number) => {
      channel.track({
        userId: user.id,
        userName: user.user_metadata.name || user.email,
        cursor: { row, col },
        online_at: new Date().toISOString()
      });
    };

    return () => {
      channel.unsubscribe();
    };
  }, [sheetId]);

  return { presences, updateCursor };
}
```

---

## 5. Simultaneous Editing

### Handle Concurrent Edits

```typescript
function useRealtimeRowUpdates(sheetId: string) {
  const supabase = getSupabaseClient();
  const [rows, setRows] = useState([]);
  const [pendingUpdates, setPendingUpdates] = useState(new Map());

  useEffect(() => {
    // Load initial rows
    supabase
      .from('rows')
      .select('*')
      .eq('sheet_id', sheetId)
      .then(({ data }) => {
        if (data) setRows(data);
      });

    // Subscribe to changes
    const subscription = supabase
      .channel(`rows-${sheetId}`)
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'rows',
          filter: `sheet_id=eq.${sheetId}`
        },
        (payload) => {
          if (payload.eventType === 'UPDATE') {
            // Check if this is our own update (pending)
            const updateId = pendingUpdates.get(payload.new.id);
            if (updateId && updateId === payload.new.updated_at) {
              // This is our update, remove from pending
              setPendingUpdates(prev => {
                const next = new Map(prev);
                next.delete(payload.new.id);
                return next;
              });
            } else {
              // This is someone else's update
              setRows(prev => prev.map(row =>
                row.id === payload.new.id ? payload.new : row
              ));
            }
          } else if (payload.eventType === 'INSERT') {
            setRows(prev => [...prev, payload.new]);
          } else if (payload.eventType === 'DELETE') {
            setRows(prev => prev.filter(row => row.id !== payload.old.id));
          }
        }
      )
      .subscribe();

    return () => {
      subscription.unsubscribe();
    };
  }, [sheetId]);

  const updateRow = async (rowId: string, updates: any) => {
    // Optimistically update UI
    setRows(prev => prev.map(row =>
      row.id === rowId ? { ...row, ...updates } : row
    ));

    // Track pending update
    const timestamp = new Date().toISOString();
    setPendingUpdates(prev => new Map(prev).set(rowId, timestamp));

    // Send update to server
    const { data, error } = await supabase
      .from('rows')
      .update({
        ...updates,
        updated_at: timestamp
      })
      .eq('id', rowId)
      .select()
      .single();

    if (error) {
      // Revert optimistic update on error
      setRows(prev => prev.map(row =>
        row.id === rowId ? { ...row } : row
      ));
      setPendingUpdates(prev => {
        const next = new Map(prev);
        next.delete(rowId);
        return next;
      });
    }
  };

  return { rows, updateRow };
}
```

### Conflict Resolution

```typescript
function useConflictResolution(sheetId: string) {
  const supabase = getSupabaseClient();
  const [conflicts, setConflicts] = useState([]);

  const resolveConflict = async (rowId: string, resolution: 'mine' | 'theirs' | 'merge') => {
    if (resolution === 'mine') {
      // Keep our version
      // (already applied optimistically)
    } else if (resolution === 'theirs') {
      // Revert to server version
      const { data } = await supabase
        .from('rows')
        .select('*')
        .eq('id', rowId)
        .single();
      
      if (data) {
        updateRowInUI(data);
      }
    } else if (resolution === 'merge') {
      // Merge both versions
      // Implement merge logic
    }

    // Remove conflict
    setConflicts(prev => prev.filter(c => c.rowId !== rowId));
  };

  return { conflicts, resolveConflict };
}
```

---

## 6. Presence System

### Track Who's Online

```typescript
function usePresence(sheetId: string) {
  const supabase = getSupabaseClient();
  const [onlineUsers, setOnlineUsers] = useState([]);

  useEffect(() => {
    const { data: { user } } = await supabase.auth.getUser();
    const channel = supabase.channel(`presence-${sheetId}`);

    channel
      .on('presence', { event: 'sync' }, () => {
        const state = channel.presenceState();
        const users = Object.values(state).flat().map(presence => ({
          userId: presence.userId,
          userName: presence.userName,
          online_at: presence.online_at
        }));
        setOnlineUsers(users);
      })
      .on('presence', { event: 'join' }, ({ key, newPresences }) => {
        console.log('User joined:', newPresences);
      })
      .on('presence', { event: 'leave' }, ({ key, leftPresences }) => {
        console.log('User left:', leftPresences);
      })
      .subscribe(async (status) => {
        if (status === 'SUBSCRIBED') {
          await channel.track({
            userId: user.id,
            userName: user.user_metadata.name || user.email,
            online_at: new Date().toISOString()
          });
        }
      });

    return () => {
      channel.unsubscribe();
    };
  }, [sheetId]);

  return onlineUsers;
}
```

### Display Online Users

```typescript
function OnlineUsersList({ sheetId }) {
  const onlineUsers = usePresence(sheetId);

  return (
    <div className="online-users">
      <h3>Online Users ({onlineUsers.length})</h3>
      {onlineUsers.map(user => (
        <div key={user.userId} className="user-badge">
          <span className="status-indicator" />
          {user.userName}
        </div>
      ))}
    </div>
  );
}
```

---

## 7. React Hook Example

### Complete Real-time Hook

```typescript
import { useEffect, useState, useCallback } from 'react';
import { getSupabaseClient } from './services/supabaseService';
import type { RealtimeChannel } from '@supabase/supabase-js';

interface UseRealtimeOptions {
  table: string;
  filter?: string;
  onInsert?: (payload: any) => void;
  onUpdate?: (payload: any) => void;
  onDelete?: (payload: any) => void;
}

export function useRealtime<T>(options: UseRealtimeOptions) {
  const supabase = getSupabaseClient();
  const [channel, setChannel] = useState<RealtimeChannel | null>(null);
  const [isConnected, setIsConnected] = useState(false);

  useEffect(() => {
    const channelName = `realtime-${options.table}-${Date.now()}`;
    const newChannel = supabase.channel(channelName);

    newChannel
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: options.table,
          filter: options.filter
        },
        (payload) => {
          switch (payload.eventType) {
            case 'INSERT':
              options.onInsert?.(payload.new);
              break;
            case 'UPDATE':
              options.onUpdate?.(payload.new);
              break;
            case 'DELETE':
              options.onDelete?.(payload.old);
              break;
          }
        }
      )
      .subscribe((status) => {
        setIsConnected(status === 'SUBSCRIBED');
      });

    setChannel(newChannel);

    return () => {
      newChannel.unsubscribe();
    };
  }, [options.table, options.filter]);

  return { channel, isConnected };
}
```

### Usage

```typescript
function SheetComponent({ sheetId }) {
  const [rows, setRows] = useState([]);

  useRealtime({
    table: 'rows',
    filter: `sheet_id=eq.${sheetId}`,
    onInsert: (newRow) => {
      setRows(prev => [...prev, newRow]);
    },
    onUpdate: (updatedRow) => {
      setRows(prev => prev.map(row =>
        row.id === updatedRow.id ? updatedRow : row
      ));
    },
    onDelete: (deletedRow) => {
      setRows(prev => prev.filter(row => row.id !== deletedRow.id));
    }
  });

  return (
    <div>
      {rows.map(row => (
        <RowComponent key={row.id} row={row} />
      ))}
    </div>
  );
}
```

---

## 8. Best Practices

### 1. Always Unsubscribe

```typescript
// ✅ Good: Cleanup subscription
useEffect(() => {
  const subscription = supabase
    .channel('rows-changes')
    .on('postgres_changes', {...}, callback)
    .subscribe();

  return () => {
    subscription.unsubscribe();
  };
}, []);

// ❌ Bad: Memory leak
useEffect(() => {
  supabase
    .channel('rows-changes')
    .on('postgres_changes', {...}, callback)
    .subscribe();
  // No cleanup!
}, []);
```

### 2. Use Unique Channel Names

```typescript
// ✅ Good: Unique channel name
const channel = supabase.channel(`rows-${sheetId}-${userId}`);

// ❌ Avoid: Generic names (can conflict)
const channel = supabase.channel('rows');
```

### 3. Handle Connection Status

```typescript
const subscription = supabase
  .channel('rows-changes')
  .on('postgres_changes', {...}, callback)
  .subscribe((status) => {
    if (status === 'SUBSCRIBED') {
      console.log('Connected to real-time');
    } else if (status === 'CHANNEL_ERROR') {
      console.error('Connection error');
    }
  });
```

### 4. Debounce Rapid Updates

```typescript
import { debounce } from 'lodash';

const debouncedUpdate = debounce((row) => {
  updateRowInUI(row);
}, 300);

subscription.on('postgres_changes', {...}, (payload) => {
  debouncedUpdate(payload.new);
});
```

### 5. Filter Subscriptions

```typescript
// ✅ Good: Filter to specific data
.on('postgres_changes', {
  table: 'rows',
  filter: `sheet_id=eq.${sheetId}`  // Only this sheet
})

// ❌ Avoid: Subscribe to everything
.on('postgres_changes', {
  table: 'rows'  // All rows in all sheets
})
```

### 6. Handle Own Updates

```typescript
// Track your own updates to avoid duplicate UI updates
const myUpdateIds = new Set();

const updateRow = async (rowId, data) => {
  const updateId = `${rowId}-${Date.now()}`;
  myUpdateIds.add(updateId);

  await supabase
    .from('rows')
    .update(data)
    .eq('id', rowId);

  // Remove after a delay
  setTimeout(() => myUpdateIds.delete(updateId), 1000);
};

subscription.on('postgres_changes', {...}, (payload) => {
  // Skip if this is our own update
  if (myUpdateIds.has(payload.new.id)) {
    return;
  }
  
  updateRowInUI(payload.new);
});
```

---

## 9. Error Handling

### Handle Connection Errors

```typescript
const subscription = supabase
  .channel('rows-changes')
  .on('postgres_changes', {...}, callback)
  .subscribe((status) => {
    if (status === 'SUBSCRIBED') {
      console.log('Connected');
    } else if (status === 'CHANNEL_ERROR') {
      console.error('Connection error, retrying...');
      // Retry logic
      setTimeout(() => {
        subscription.subscribe();
      }, 1000);
    } else if (status === 'TIMED_OUT') {
      console.error('Connection timed out');
    } else if (status === 'CLOSED') {
      console.log('Connection closed');
    }
  });
```

### Handle Reconnection

```typescript
function useRealtimeWithReconnect(options) {
  const [retryCount, setRetryCount] = useState(0);
  const maxRetries = 5;

  useEffect(() => {
    let subscription;

    const connect = () => {
      subscription = supabase
        .channel(`realtime-${options.table}`)
        .on('postgres_changes', {...}, options.callback)
        .subscribe((status) => {
          if (status === 'SUBSCRIBED') {
            setRetryCount(0);
          } else if (status === 'CHANNEL_ERROR' && retryCount < maxRetries) {
            setTimeout(() => {
              setRetryCount(prev => prev + 1);
              connect();
            }, 1000 * (retryCount + 1));
          }
        });
    };

    connect();

    return () => {
      subscription?.unsubscribe();
    };
  }, [options.table, retryCount]);
}
```

---

## 10. Summary

### Key Points

1. ✅ **WebSocket-based** - Real-time updates via WebSockets
2. ✅ **Automatic** - No backend code needed
3. ✅ **RLS Protected** - Security enforced automatically
4. ✅ **Presence** - Track who's online
5. ✅ **Broadcast** - Send custom messages

### Quick Reference

```typescript
// Subscribe to changes
const subscription = supabase
  .channel('changes')
  .on('postgres_changes', {
    event: '*',
    schema: 'public',
    table: 'rows',
    filter: `sheet_id=eq.${sheetId}`
  }, (payload) => {
    console.log('Change:', payload);
  })
  .subscribe();

// Cleanup
subscription.unsubscribe();
```

---

**Real-time collaboration is built into Supabase - just subscribe to changes!** 🚀
