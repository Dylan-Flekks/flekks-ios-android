import React, { useState } from 'react';

export default function FlekksApp() {
  const [currentTab, setCurrentTab] = useState('home');
  const [mode, setMode] = useState('consumer');
  const [activeModal, setActiveModal] = useState(null);
  const [signupStep, setSignupStep] = useState(1);
  const [selectedPills, setSelectedPills] = useState([]);

  const togglePill = (pill) => {
    setSelectedPills(prev =>
      prev.includes(pill) ? prev.filter(p => p !== pill) : [...prev, pill]
    );
  };

  const styles = {
    container: {
      width: '100%',
      maxWidth: '390px',
      height: '844px',
      background: '#0f0f1a',
      borderRadius: '44px',
      overflow: 'hidden',
      position: 'relative',
      fontFamily: '-apple-system, BlinkMacSystemFont, "SF Pro Display", sans-serif',
      margin: '0 auto',
    },
    dynamicIsland: {
      position: 'absolute',
      top: '12px',
      left: '50%',
      transform: 'translateX(-50%)',
      width: '126px',
      height: '37px',
      background: '#000',
      borderRadius: '20px',
      zIndex: 1000,
    },
    statusBar: {
      height: '54px',
      padding: '14px 24px 0',
      display: 'flex',
      justifyContent: 'space-between',
      alignItems: 'flex-start',
      color: '#fff',
      fontSize: '14px',
      fontWeight: 600,
    },
    page: {
      height: 'calc(100% - 54px - 83px)',
      overflowY: 'auto',
      padding: '0 20px 20px',
    },
    tabBar: {
      position: 'absolute',
      bottom: 0,
      left: 0,
      right: 0,
      height: '83px',
      background: 'rgba(20, 20, 35, 0.95)',
      backdropFilter: 'blur(20px)',
      borderTop: '1px solid rgba(255,255,255,0.1)',
      display: 'flex',
      justifyContent: 'space-around',
      alignItems: 'flex-start',
      paddingTop: '10px',
    },
    tabItem: {
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      gap: '4px',
      cursor: 'pointer',
      background: 'none',
      border: 'none',
      padding: 0,
    },
    h1: { fontSize: '28px', color: '#fff', fontWeight: 700, marginBottom: '20px' },
    h2: { fontSize: '20px', color: '#fff', fontWeight: 600, margin: '20px 0 12px' },
    h3: { fontSize: '16px', color: '#fff', fontWeight: 600 },
    modalOverlay: {
      position: 'absolute',
      top: 0, left: 0, right: 0, bottom: 0,
      background: 'rgba(0,0,0,0.8)',
      zIndex: 100,
    },
    modalContent: {
      position: 'absolute',
      bottom: 0, left: 0, right: 0,
      background: '#1a1a2e',
      borderRadius: '24px 24px 0 0',
      maxHeight: '85%',
      overflowY: 'auto',
    },
    modalFullscreen: {
      position: 'absolute',
      top: 0, left: 0, right: 0, bottom: 0,
      background: '#0f0f1a',
      overflowY: 'auto',
    },
    btn: {
      width: '100%',
      background: '#00D9A5',
      color: '#000',
      padding: '18px',
      borderRadius: '16px',
      fontSize: '17px',
      fontWeight: 600,
      textAlign: 'center',
      cursor: 'pointer',
      border: 'none',
    },
  };

  // Components
  const QuickBtn = ({ icon, label, gradient, onClick }) => (
    <button onClick={onClick} style={{
      flex: 1, padding: '16px 12px', borderRadius: '16px',
      background: 'rgba(255,255,255,0.08)', border: '1px solid rgba(255,255,255,0.1)',
      display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '8px', cursor: 'pointer',
    }}>
      <div style={{
        width: '40px', height: '40px', borderRadius: '12px',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        fontSize: '20px', background: gradient,
      }}>{icon}</div>
      <span style={{ color: '#fff', fontSize: '12px', fontWeight: 500 }}>{label}</span>
    </button>
  );

  const CategoryTile = ({ icon, name, gradient, onClick }) => (
    <button onClick={onClick} style={{
      padding: '20px 16px', borderRadius: '16px', background: gradient,
      border: 'none', cursor: 'pointer', textAlign: 'left',
    }}>
      <div style={{ fontSize: '28px', marginBottom: '8px' }}>{icon}</div>
      <div style={{ color: '#fff', fontSize: '14px', fontWeight: 600 }}>{name}</div>
    </button>
  );

  const RoutineCard = ({ icon, title, desc, duration, rating, onClick }) => (
    <button onClick={onClick} style={{
      background: 'rgba(255,255,255,0.05)', borderRadius: '16px', padding: '12px',
      display: 'flex', gap: '12px', marginBottom: '12px', cursor: 'pointer',
      border: 'none', width: '100%', textAlign: 'left',
    }}>
      <div style={{
        width: '80px', height: '80px', borderRadius: '12px',
        background: 'linear-gradient(135deg, #374151, #1f2937)',
        display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '32px', flexShrink: 0,
      }}>{icon}</div>
      <div style={{ flex: 1 }}>
        <div style={{ color: '#fff', fontSize: '15px', fontWeight: 600, marginBottom: '4px' }}>{title}</div>
        <div style={{ color: 'rgba(255,255,255,0.5)', fontSize: '12px', marginBottom: '8px' }}>{desc}</div>
        <div style={{ display: 'flex', gap: '12px' }}>
          <span style={{ fontSize: '12px', color: 'rgba(255,255,255,0.6)' }}>⏱️ {duration}</span>
          {rating && <span style={{ fontSize: '12px', color: 'rgba(255,255,255,0.6)' }}>⭐ {rating}</span>}
        </div>
      </div>
    </button>
  );

  const ProviderCard = ({ icon, name, creds, rating, price, onClick }) => (
    <button onClick={onClick} style={{
      background: 'rgba(255,255,255,0.05)', borderRadius: '16px', padding: '16px',
      display: 'flex', gap: '14px', marginBottom: '12px', cursor: 'pointer',
      border: 'none', width: '100%', textAlign: 'left',
    }}>
      <div style={{
        width: '60px', height: '60px', borderRadius: '50%',
        background: 'linear-gradient(135deg, #00D9A5, #00B4D8)',
        display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '24px', flexShrink: 0,
      }}>{icon}</div>
      <div style={{ flex: 1 }}>
        <div style={{ color: '#fff', fontSize: '16px', fontWeight: 600, display: 'flex', alignItems: 'center', gap: '6px' }}>
          {name} <span style={{ color: '#00D9A5', fontSize: '14px' }}>✓</span>
        </div>
        <div style={{ color: 'rgba(255,255,255,0.5)', fontSize: '13px', margin: '2px 0 8px' }}>{creds}</div>
        <div style={{ display: 'flex', gap: '16px' }}>
          <span style={{ fontSize: '13px', color: 'rgba(255,255,255,0.7)' }}>⭐ {rating}</span>
          <span style={{ fontSize: '13px', color: '#00D9A5', fontWeight: 600 }}>{price}</span>
        </div>
      </div>
    </button>
  );

  const MovementItem = ({ icon, name, count, score, gain, percent, onClick }) => (
    <button onClick={onClick} style={{
      background: 'rgba(255,255,255,0.05)', borderRadius: '16px', padding: '16px',
      marginBottom: '12px', cursor: 'pointer', border: 'none', width: '100%', textAlign: 'left',
    }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <div style={{
            width: '44px', height: '44px', borderRadius: '12px',
            background: 'rgba(0,217,165,0.2)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '20px',
          }}>{icon}</div>
          <div>
            <div style={{ color: '#fff', fontSize: '15px', fontWeight: 600 }}>{name}</div>
            <div style={{ color: 'rgba(255,255,255,0.5)', fontSize: '12px' }}>{count}</div>
          </div>
        </div>
        <div style={{ textAlign: 'right' }}>
          <div style={{ color: '#00D9A5', fontSize: '20px', fontWeight: 700 }}>{score}</div>
          <div style={{ color: 'rgba(0,217,165,0.8)', fontSize: '12px' }}>{gain}</div>
        </div>
      </div>
      <div style={{ height: '6px', background: 'rgba(255,255,255,0.1)', borderRadius: '3px', overflow: 'hidden' }}>
        <div style={{ height: '100%', width: `${percent}%`, background: 'linear-gradient(90deg, #00D9A5, #00B4D8)', borderRadius: '3px' }} />
      </div>
    </button>
  );

  const Pill = ({ label, active, onClick }) => (
    <button onClick={onClick} style={{
      background: active ? '#00D9A5' : 'rgba(255,255,255,0.1)',
      border: `1px solid ${active ? '#00D9A5' : 'rgba(255,255,255,0.2)'}`,
      borderRadius: '20px', padding: '10px 16px',
      color: active ? '#000' : '#fff', fontSize: '14px', cursor: 'pointer',
    }}>{label}</button>
  );

  const TabItem = ({ icon, label, active, onClick }) => (
    <button onClick={onClick} style={{
      ...styles.tabItem, opacity: active ? 1 : 0.5,
    }}>
      <div style={{ fontSize: '20px', color: active ? '#00D9A5' : '#fff' }}>{icon}</div>
      <div style={{ fontSize: '10px', color: active ? '#00D9A5' : '#fff' }}>{label}</div>
    </button>
  );

  // Pages
  const HomePage = () => (
    <div style={styles.page}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
        <div>
          <div style={{ color: 'rgba(255,255,255,0.6)', fontSize: '14px' }}>Good morning</div>
          <div style={{ color: '#fff', fontSize: '24px', fontWeight: 700 }}>Sarah 👋</div>
        </div>
        <div style={{
          width: '44px', height: '44px', borderRadius: '50%',
          background: 'linear-gradient(135deg, #00D9A5, #00B4D8)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontSize: '18px', color: '#fff', fontWeight: 600,
        }}>S</div>
      </div>

      <div style={{ display: 'flex', gap: '12px', marginBottom: '24px' }}>
        <QuickBtn icon="📹" label="Assess" gradient="linear-gradient(135deg, #FF6B6B, #FF8E53)" onClick={() => setActiveModal('assess')} />
        <QuickBtn icon="📈" label="Progress" gradient="linear-gradient(135deg, #00D9A5, #00B4D8)" onClick={() => setActiveModal('progress-reel')} />
      </div>

      <button onClick={() => setActiveModal('routine-detail')} style={{
        background: 'linear-gradient(135deg, #1e3a5f, #0d1f33)', borderRadius: '24px',
        padding: '24px', marginBottom: '24px', position: 'relative', border: 'none',
        width: '100%', textAlign: 'left', cursor: 'pointer',
      }}>
        <div style={{ background: 'rgba(255,255,255,0.2)', padding: '6px 12px', borderRadius: '20px', fontSize: '11px', color: '#fff', display: 'inline-block', marginBottom: '12px' }}>⭐ Featured</div>
        <div style={{ fontSize: '22px', color: '#fff', fontWeight: 700, marginBottom: '8px' }}>Desk Worker Relief</div>
        <div style={{ color: 'rgba(255,255,255,0.7)', fontSize: '14px', marginBottom: '16px' }}>Release tension from hours of sitting</div>
        <div style={{ display: 'flex', gap: '16px' }}>
          <span style={{ color: 'rgba(255,255,255,0.8)', fontSize: '13px' }}>⏱️ 15 min</span>
          <span style={{ color: 'rgba(255,255,255,0.8)', fontSize: '13px' }}>⭐ 4.9</span>
        </div>
        <div style={{
          position: 'absolute', right: '20px', bottom: '20px',
          width: '56px', height: '56px', background: '#00D9A5', borderRadius: '50%',
          display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '24px', color: '#000',
        }}>▶</div>
      </button>

      <div style={styles.h2}>Browse by Goal</div>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: '12px', marginBottom: '24px' }}>
        <CategoryTile icon="💻" name="Desk Worker" gradient="linear-gradient(135deg, #3B82F6, #1D4ED8)" onClick={() => setActiveModal('category')} />
        <CategoryTile icon="🌅" name="Morning" gradient="linear-gradient(135deg, #F59E0B, #D97706)" onClick={() => setActiveModal('category')} />
        <CategoryTile icon="💪" name="Post-Workout" gradient="linear-gradient(135deg, #EF4444, #DC2626)" onClick={() => setActiveModal('category')} />
        <CategoryTile icon="🌙" name="Sleep" gradient="linear-gradient(135deg, #8B5CF6, #6D28D9)" onClick={() => setActiveModal('category')} />
      </div>

      <div style={styles.h2}>Popular Routines</div>
      <RoutineCard icon="🧘" title="Hip Opener Flow" desc="Release tight hip flexors" duration="12 min" rating="4.8" onClick={() => setActiveModal('routine-detail')} />
      <RoutineCard icon="🙆" title="Shoulder Release" desc="Melt away upper body tension" duration="10 min" rating="4.9" onClick={() => setActiveModal('routine-detail')} />
    </div>
  );

  const DiscoverPage = () => (
    <div style={styles.page}>
      <div style={styles.h1}>Discover</div>
      <div style={{
        background: 'rgba(255,255,255,0.08)', borderRadius: '12px',
        padding: '14px 16px', display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '24px',
      }}>
        <span style={{ color: 'rgba(255,255,255,0.4)' }}>🔍</span>
        <input placeholder="Search routines, providers..." style={{
          background: 'none', border: 'none', color: '#fff', fontSize: '16px', width: '100%', outline: 'none',
        }} />
      </div>

      <div style={styles.h2}>Categories</div>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: '12px', marginBottom: '24px' }}>
        <CategoryTile icon="💻" name="Desk Worker" gradient="linear-gradient(135deg, #3B82F6, #1D4ED8)" onClick={() => setActiveModal('category')} />
        <CategoryTile icon="🌅" name="Morning" gradient="linear-gradient(135deg, #F59E0B, #D97706)" onClick={() => setActiveModal('category')} />
        <CategoryTile icon="💪" name="Post-Workout" gradient="linear-gradient(135deg, #EF4444, #DC2626)" onClick={() => setActiveModal('category')} />
        <CategoryTile icon="🌙" name="Sleep" gradient="linear-gradient(135deg, #8B5CF6, #6D28D9)" onClick={() => setActiveModal('category')} />
        <CategoryTile icon="🩹" name="Pain Relief" gradient="linear-gradient(135deg, #10B981, #059669)" onClick={() => setActiveModal('category')} />
        <CategoryTile icon="🎯" name="Focus" gradient="linear-gradient(135deg, #EC4899, #DB2777)" onClick={() => setActiveModal('category')} />
      </div>

      <div style={styles.h2}>Book a Specialist</div>
      <ProviderCard icon="👩‍⚕️" name="Dr. Emily Chen" creds="DPT, Orthopedic Specialist" rating="4.9" price="$85/session" onClick={() => setActiveModal('booking')} />
      <ProviderCard icon="🧘‍♂️" name="Marcus Johnson" creds="Certified Stretch Therapist" rating="4.8" price="$65/session" onClick={() => setActiveModal('booking')} />
    </div>
  );

  const AssessPage = () => (
    <div style={styles.page}>
      <div style={styles.h1}>Assess</div>
      <button onClick={() => setActiveModal('assess')} style={{
        background: 'linear-gradient(135deg, #00D9A5, #00B4D8)', borderRadius: '24px',
        padding: '32px 24px', textAlign: 'center', marginBottom: '32px', cursor: 'pointer',
        border: 'none', width: '100%',
      }}>
        <div style={{ fontSize: '48px', marginBottom: '16px' }}>📹</div>
        <div style={{ color: '#000', fontSize: '20px', fontWeight: 600, marginBottom: '8px' }}>Start New Assessment</div>
        <div style={{ color: 'rgba(0,0,0,0.7)', fontSize: '14px' }}>Record your movement and get AI-powered feedback</div>
      </button>

      <div style={{ color: '#fff', fontSize: '18px', fontWeight: 600, marginBottom: '16px' }}>What's bothering you?</div>
      <input placeholder="Describe your pain or tightness..." style={{
        background: 'rgba(255,255,255,0.08)', border: '1px solid rgba(255,255,255,0.1)',
        borderRadius: '16px', padding: '16px', color: '#fff', fontSize: '16px',
        width: '100%', marginBottom: '16px', outline: 'none', boxSizing: 'border-box',
      }} />

      <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px', marginBottom: '24px' }}>
        {['Low back pain', 'Hip tightness', 'Shoulder issues', 'Neck stiffness'].map(pill => (
          <Pill key={pill} label={pill} active={selectedPills.includes(pill)} onClick={() => togglePill(pill)} />
        ))}
      </div>

      <div style={styles.h2}>Recommended Tests</div>
      <RoutineCard icon="🏃" title="Forward Fold Test" desc="Measures hamstring & lower back flexibility" duration="30 sec" />
      <RoutineCard icon="🧎" title="Deep Squat Hold" desc="Tests hip, ankle & thoracic mobility" duration="30 sec" />
    </div>
  );

  const ProgressPage = () => (
    <div style={styles.page}>
      <div style={styles.h1}>Progress</div>
      <div style={{
        background: 'linear-gradient(135deg, #00D9A5, #00B4D8)', borderRadius: '24px',
        padding: '32px', textAlign: 'center', marginBottom: '24px',
      }}>
        <div style={{ color: 'rgba(0,0,0,0.6)', fontSize: '14px', marginBottom: '8px' }}>Overall Mobility Score</div>
        <div style={{ color: '#000', fontSize: '64px', fontWeight: 800, lineHeight: 1 }}>78<span style={{ fontSize: '24px', fontWeight: 400 }}>/100</span></div>
        <div style={{
          display: 'inline-flex', alignItems: 'center', gap: '4px',
          background: 'rgba(0,0,0,0.2)', padding: '8px 16px', borderRadius: '20px',
          marginTop: '16px', color: '#000', fontWeight: 600,
        }}>↑ +12 from start</div>
      </div>

      <div style={styles.h2}>Tracked Movements</div>
      <MovementItem icon="🏃" name="Forward Fold" count="8 assessments" score="142°" gain="+26°" percent={78} onClick={() => setActiveModal('progress-reel')} />
      <MovementItem icon="🧎" name="Deep Squat" count="6 assessments" score="95°" gain="+18°" percent={65} onClick={() => setActiveModal('progress-reel')} />
      <MovementItem icon="🦵" name="90/90 Hip" count="5 assessments" score="82°" gain="+15°" percent={58} onClick={() => setActiveModal('progress-reel')} />
    </div>
  );

  const ProfilePage = () => (
    <div style={styles.page}>
      <div style={{ textAlign: 'center', marginBottom: '32px' }}>
        <div style={{
          width: '100px', height: '100px', borderRadius: '50%',
          background: 'linear-gradient(135deg, #00D9A5, #00B4D8)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontSize: '40px', color: '#fff', margin: '0 auto 16px',
        }}>S</div>
        <div style={{ color: '#fff', fontSize: '24px', fontWeight: 700 }}>Sarah Mitchell</div>
        <div style={{ color: 'rgba(255,255,255,0.5)', fontSize: '14px' }}>@sarahm</div>
      </div>

      <div style={{ display: 'flex', justifyContent: 'center', gap: '32px', margin: '24px 0' }}>
        {[['24', 'Assessments'], ['78', 'Score'], ['12', 'Day Streak']].map(([val, label]) => (
          <div key={label} style={{ textAlign: 'center' }}>
            <div style={{ color: '#fff', fontSize: '24px', fontWeight: 700 }}>{val}</div>
            <div style={{ color: 'rgba(255,255,255,0.5)', fontSize: '12px' }}>{label}</div>
          </div>
        ))}
      </div>

      <div style={{ background: 'rgba(255,255,255,0.08)', borderRadius: '12px', padding: '4px', display: 'flex', marginBottom: '24px' }}>
        <button onClick={() => setMode('consumer')} style={{
          flex: 1, padding: '12px', borderRadius: '10px', textAlign: 'center',
          fontSize: '14px', fontWeight: 500, cursor: 'pointer', border: 'none',
          background: mode === 'consumer' ? '#00D9A5' : 'transparent',
          color: mode === 'consumer' ? '#000' : 'rgba(255,255,255,0.5)',
        }}>Consumer</button>
        <button onClick={() => setMode('provider')} style={{
          flex: 1, padding: '12px', borderRadius: '10px', textAlign: 'center',
          fontSize: '14px', fontWeight: 500, cursor: 'pointer', border: 'none',
          background: mode === 'provider' ? '#00D9A5' : 'transparent',
          color: mode === 'provider' ? '#000' : 'rgba(255,255,255,0.5)',
        }}>Provider</button>
      </div>

      {mode === 'consumer' && (
        <button onClick={() => setActiveModal('provider-signup')} style={{
          background: 'linear-gradient(135deg, #A855F7, #6366F1)', borderRadius: '20px',
          padding: '24px', marginBottom: '24px', cursor: 'pointer', border: 'none',
          width: '100%', textAlign: 'left',
        }}>
          <div style={{ color: '#fff', fontSize: '18px', fontWeight: 600, marginBottom: '8px' }}>Become a Provider 🎓</div>
          <div style={{ color: 'rgba(255,255,255,0.8)', fontSize: '14px', marginBottom: '12px' }}>Share your expertise and earn money</div>
          <div style={{ color: '#fff', fontSize: '24px', fontWeight: 700 }}>Earn $0.30 per 100 views</div>
        </button>
      )}

      <div style={{ background: 'rgba(255,255,255,0.05)', borderRadius: '16px', overflow: 'hidden' }}>
        {['🔔 Notifications', '🔒 Privacy', '❓ Help & Support', 'ℹ️ About FLEKKS'].map((item, i, arr) => (
          <div key={item} style={{
            padding: '16px', display: 'flex', justifyContent: 'space-between', alignItems: 'center',
            borderBottom: i < arr.length - 1 ? '1px solid rgba(255,255,255,0.05)' : 'none', cursor: 'pointer',
          }}>
            <span style={{ color: '#fff', fontSize: '15px' }}>{item}</span>
            <span style={{ color: 'rgba(255,255,255,0.3)' }}>›</span>
          </div>
        ))}
      </div>
    </div>
  );

  // Provider Pages
  const ProviderDashboard = () => (
    <div style={styles.page}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
        <div>
          <div style={{ color: 'rgba(255,255,255,0.6)', fontSize: '14px' }}>Welcome back</div>
          <div style={{ color: '#fff', fontSize: '24px', fontWeight: 700 }}>Dr. Sarah 👩‍⚕️</div>
        </div>
        <div style={{ position: 'relative' }}>
          <div style={{
            width: '44px', height: '44px', borderRadius: '50%',
            background: 'linear-gradient(135deg, #00D9A5, #00B4D8)',
            display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '18px', color: '#fff',
          }}>S</div>
          <div style={{ position: 'absolute', top: '-2px', right: '-2px', width: '8px', height: '8px', background: '#EF4444', borderRadius: '50%' }} />
        </div>
      </div>

      <div style={{
        background: 'linear-gradient(135deg, #10B981, #059669)', borderRadius: '24px',
        padding: '24px', marginBottom: '24px',
      }}>
        <div style={{ color: 'rgba(255,255,255,0.8)', fontSize: '14px' }}>This Month's Earnings</div>
        <div style={{ color: '#fff', fontSize: '42px', fontWeight: 800, margin: '8px 0' }}>$847.50</div>
        <div style={{ display: 'flex', gap: '24px' }}>
          <span style={{ color: 'rgba(255,255,255,0.8)', fontSize: '13px' }}>Pending: <strong style={{ color: '#fff' }}>$124.20</strong></span>
          <span style={{ color: 'rgba(255,255,255,0.8)', fontSize: '13px' }}>Views: <strong style={{ color: '#fff' }}>282.5K</strong></span>
        </div>
      </div>

      <div style={{ display: 'flex', gap: '12px', marginBottom: '24px' }}>
        {[['12', 'ROUTINES'], ['847K', 'TOTAL VIEWS'], ['+23%', 'THIS WEEK']].map(([val, label]) => (
          <div key={label} style={{
            flex: 1, background: 'rgba(255,255,255,0.05)', borderRadius: '16px',
            padding: '16px', textAlign: 'center',
          }}>
            <div style={{ color: '#fff', fontSize: '24px', fontWeight: 700 }}>{val}</div>
            <div style={{ color: 'rgba(255,255,255,0.5)', fontSize: '11px', marginTop: '4px' }}>{label}</div>
          </div>
        ))}
      </div>

      <div style={styles.h2}>Patient Shares</div>
      {[['J', 'John D.', 'Forward Fold • 2h ago'], ['M', 'Maria S.', 'Deep Squat • 5h ago']].map(([init, name, detail]) => (
        <div key={name} style={{
          background: 'rgba(255,255,255,0.05)', borderRadius: '16px', padding: '16px',
          marginBottom: '12px', display: 'flex', gap: '12px', alignItems: 'center',
        }}>
          <div style={{
            width: '48px', height: '48px', borderRadius: '50%',
            background: 'linear-gradient(135deg, #3B82F6, #1D4ED8)',
            display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '18px', color: '#fff',
          }}>{init}</div>
          <div style={{ flex: 1 }}>
            <div style={{ color: '#fff', fontSize: '15px', fontWeight: 600 }}>{name}</div>
            <div style={{ color: 'rgba(255,255,255,0.5)', fontSize: '13px' }}>{detail}</div>
          </div>
          <div style={{ background: '#00D9A5', color: '#000', padding: '8px 16px', borderRadius: '20px', fontSize: '13px', fontWeight: 600 }}>Review</div>
        </div>
      ))}
    </div>
  );

  const ProviderContent = () => (
    <div style={styles.page}>
      <div style={styles.h1}>Content</div>
      <button onClick={() => setActiveModal('content-studio')} style={{
        background: 'linear-gradient(135deg, #A855F7, #6366F1)', borderRadius: '20px',
        padding: '24px', textAlign: 'center', marginBottom: '24px', cursor: 'pointer',
        border: 'none', width: '100%',
      }}>
        <div style={{ color: '#fff', fontSize: '18px', fontWeight: 600, marginBottom: '8px' }}>📹 Upload New Routine</div>
        <div style={{ color: 'rgba(255,255,255,0.8)', fontSize: '14px' }}>Share your expertise and start earning</div>
      </button>

      <div style={styles.h2}>Your Routines</div>
      {[['💻', 'Desk Worker Relief', '124K', '$372.00'], ['🧘', 'Hip Opener Flow', '89K', '$267.00'], ['🙆', 'Shoulder Release', '45K', '$135.00']].map(([icon, title, views, earnings]) => (
        <div key={title} style={{
          background: 'rgba(255,255,255,0.05)', borderRadius: '16px', padding: '12px',
          display: 'flex', gap: '12px', marginBottom: '12px',
        }}>
          <div style={{
            width: '100px', height: '70px', borderRadius: '10px',
            background: 'linear-gradient(135deg, #374151, #1f2937)',
            display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '28px',
          }}>{icon}</div>
          <div style={{ flex: 1 }}>
            <div style={{ color: '#fff', fontSize: '15px', fontWeight: 600, marginBottom: '8px' }}>{title}</div>
            <div style={{ display: 'flex', gap: '16px' }}>
              <span style={{ fontSize: '13px', color: 'rgba(255,255,255,0.6)' }}>👁️ {views}</span>
              <span style={{ fontSize: '13px', color: '#00D9A5', fontWeight: 600 }}>{earnings}</span>
            </div>
          </div>
        </div>
      ))}
    </div>
  );

  const ProviderEarnings = () => (
    <div style={styles.page}>
      <div style={styles.h1}>Earnings</div>
      <div style={{
        background: 'linear-gradient(135deg, #10B981, #059669)', borderRadius: '24px',
        padding: '24px', marginBottom: '24px',
      }}>
        <div style={{ color: 'rgba(255,255,255,0.8)', fontSize: '14px' }}>Total Earnings</div>
        <div style={{ color: '#fff', fontSize: '42px', fontWeight: 800, margin: '8px 0' }}>$2,847.50</div>
        <div style={{ color: 'rgba(255,255,255,0.8)', fontSize: '13px' }}>This month: <strong style={{ color: '#fff' }}>$847.50</strong></div>
      </div>

      <div style={styles.h2}>Payout History</div>
      {[['December 2024', '282,500 views', '$847.50', 'Pending'], ['November 2024', '245,000 views', '$735.00', 'Paid'], ['October 2024', '198,333 views', '$595.00', 'Paid']].map(([month, views, amount, status]) => (
        <div key={month} style={{
          background: 'rgba(255,255,255,0.05)', borderRadius: '16px', padding: '16px', marginBottom: '12px',
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
              <div style={{
                width: '44px', height: '44px', borderRadius: '12px',
                background: 'rgba(16,185,129,0.2)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '20px',
              }}>💵</div>
              <div>
                <div style={{ color: '#fff', fontSize: '15px', fontWeight: 600 }}>{month}</div>
                <div style={{ color: 'rgba(255,255,255,0.5)', fontSize: '12px' }}>{views}</div>
              </div>
            </div>
            <div style={{ textAlign: 'right' }}>
              <div style={{ color: '#00D9A5', fontSize: '20px', fontWeight: 700 }}>{amount}</div>
              <div style={{ color: status === 'Pending' ? 'rgba(0,217,165,0.8)' : 'rgba(255,255,255,0.5)', fontSize: '12px' }}>{status}</div>
            </div>
          </div>
        </div>
      ))}
    </div>
  );

  // Modals
  const RoutineDetailModal = () => (
    <div style={styles.modalOverlay} onClick={() => setActiveModal(null)}>
      <div style={styles.modalContent} onClick={e => e.stopPropagation()}>
        <div style={{
          height: '200px', background: 'linear-gradient(135deg, #1e3a5f, #0d1f33)',
          display: 'flex', alignItems: 'center', justifyContent: 'center', position: 'relative',
        }}>
          <span style={{ fontSize: '64px' }}>💻</span>
          <div style={{
            position: 'absolute', top: '16px', right: '16px',
            background: 'rgba(0,0,0,0.5)', padding: '6px 12px', borderRadius: '20px', color: '#fff', fontSize: '13px',
          }}>⏱️ 15 min</div>
        </div>
        <div style={{ padding: '24px 20px' }}>
          <div style={{ color: '#fff', fontSize: '24px', fontWeight: 700, marginBottom: '8px' }}>Desk Worker Relief</div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '16px' }}>
            <div style={{ width: '32px', height: '32px', borderRadius: '50%', background: 'linear-gradient(135deg, #00D9A5, #00B4D8)' }} />
            <span style={{ color: 'rgba(255,255,255,0.7)', fontSize: '14px' }}>Dr. Emily Chen</span>
            <span style={{ color: '#00D9A5' }}>✓</span>
          </div>
          <div style={{ display: 'flex', gap: '24px', marginBottom: '20px' }}>
            <span style={{ color: 'rgba(255,255,255,0.6)', fontSize: '14px' }}>⭐ 4.9 (2.4k)</span>
            <span style={{ color: 'rgba(255,255,255,0.6)', fontSize: '14px' }}>✅ 12.8k completed</span>
          </div>
          <p style={{ color: 'rgba(255,255,255,0.7)', fontSize: '14px', lineHeight: 1.5, marginBottom: '20px' }}>
            Release tension from hours of sitting with this comprehensive routine designed specifically for office workers.
          </p>
          <div style={styles.h3}>Target Areas</div>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px', margin: '12px 0 20px' }}>
            {['Neck', 'Shoulders', 'Lower Back', 'Hips'].map(area => (
              <span key={area} style={{ background: 'rgba(0,217,165,0.2)', color: '#00D9A5', padding: '6px 12px', borderRadius: '16px', fontSize: '13px' }}>{area}</span>
            ))}
          </div>
          <div style={styles.h3}>Benefits</div>
          <div style={{ margin: '12px 0 24px' }}>
            {['Reduces neck and shoulder tension', 'Improves posture', 'Relieves lower back stiffness', 'Opens tight hip flexors'].map(b => (
              <div key={b} style={{ display: 'flex', alignItems: 'center', gap: '10px', color: 'rgba(255,255,255,0.8)', fontSize: '14px', marginBottom: '10px' }}>
                <span style={{ color: '#00D9A5' }}>✓</span> {b}
              </div>
            ))}
          </div>
          <button onClick={() => setActiveModal('player')} style={styles.btn}>Start Routine</button>
        </div>
      </div>
    </div>
  );

  const PlayerModal = () => (
    <div style={styles.modalOverlay} onClick={() => setActiveModal(null)}>
      <div style={styles.modalFullscreen} onClick={e => e.stopPropagation()}>
        <div style={{ padding: '60px 20px 20px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <span style={{ color: '#fff', fontSize: '20px', fontWeight: 600 }}>Desk Worker Relief</span>
          <button onClick={() => setActiveModal(null)} style={{
            width: '36px', height: '36px', borderRadius: '50%', background: 'rgba(255,255,255,0.1)',
            display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', border: 'none', cursor: 'pointer',
          }}>✕</button>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '40px 20px', textAlign: 'center' }}>
          <div style={{
            width: '160px', height: '160px', borderRadius: '50%',
            background: 'linear-gradient(135deg, rgba(0,217,165,0.3), rgba(0,180,216,0.3))',
            display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '80px', marginBottom: '32px',
          }}>🙆</div>
          <div style={{ color: 'rgba(255,255,255,0.6)', fontSize: '16px', marginBottom: '8px' }}>Exercise 2 of 8</div>
          <div style={{ color: '#fff', fontSize: '28px', fontWeight: 700, marginBottom: '32px' }}>Neck Rolls</div>
          <div style={{ color: '#00D9A5', fontSize: '72px', fontWeight: 800, marginBottom: '48px' }}>0:24</div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '32px' }}>
            <button style={{
              width: '56px', height: '56px', borderRadius: '50%', background: 'rgba(255,255,255,0.1)',
              display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '24px', color: '#fff', border: 'none', cursor: 'pointer',
            }}>⏮</button>
            <button style={{
              width: '80px', height: '80px', borderRadius: '50%', background: '#00D9A5',
              display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '32px', color: '#000', border: 'none', cursor: 'pointer',
            }}>⏸</button>
            <button style={{
              width: '56px', height: '56px', borderRadius: '50%', background: 'rgba(255,255,255,0.1)',
              display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '24px', color: '#fff', border: 'none', cursor: 'pointer',
            }}>⏭</button>
          </div>
        </div>
        <div style={{ position: 'absolute', bottom: '120px', left: '20px', right: '20px' }}>
          <div style={{ height: '4px', background: 'rgba(255,255,255,0.2)', borderRadius: '2px' }}>
            <div style={{ width: '35%', height: '100%', background: '#00D9A5', borderRadius: '2px' }} />
          </div>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: '8px', color: 'rgba(255,255,255,0.5)', fontSize: '12px' }}>
            <span>2:45</span><span>15:00</span>
          </div>
        </div>
      </div>
    </div>
  );

  const ProgressReelModal = () => (
    <div style={styles.modalOverlay} onClick={() => setActiveModal(null)}>
      <div style={styles.modalFullscreen} onClick={e => e.stopPropagation()}>
        <div style={{ padding: '60px 20px 20px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <span style={{ color: '#fff', fontSize: '20px', fontWeight: 600 }}>Progress Reel</span>
          <button onClick={() => setActiveModal(null)} style={{
            width: '36px', height: '36px', borderRadius: '50%', background: 'rgba(255,255,255,0.1)',
            display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', border: 'none', cursor: 'pointer',
          }}>✕</button>
        </div>
        <div style={{ padding: '0 20px', textAlign: 'center' }}>
          <div style={{
            width: '120px', height: '120px', borderRadius: '50%',
            background: 'linear-gradient(135deg, rgba(0,217,165,0.3), rgba(0,180,216,0.3))',
            display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '56px', margin: '0 auto 24px',
          }}>🏃</div>
          <div style={{ color: '#fff', fontSize: '72px', fontWeight: 800, lineHeight: 1 }}>142°</div>
          <div style={{
            display: 'inline-flex', alignItems: 'center', gap: '6px',
            background: 'rgba(0,217,165,0.2)', color: '#00D9A5',
            padding: '10px 20px', borderRadius: '24px', fontSize: '18px', fontWeight: 600, margin: '16px 0 32px',
          }}>↑ +26° from start</div>
          <div style={{ display: 'flex', gap: '12px', justifyContent: 'center', marginBottom: '32px' }}>
            <button style={{ padding: '12px 24px', borderRadius: '24px', background: '#00D9A5', color: '#000', fontSize: '14px', fontWeight: 500, border: 'none', cursor: 'pointer' }}>Timeline</button>
            <button style={{ padding: '12px 24px', borderRadius: '24px', background: 'rgba(255,255,255,0.1)', color: 'rgba(255,255,255,0.6)', fontSize: '14px', fontWeight: 500, border: 'none', cursor: 'pointer' }}>Compare</button>
          </div>
        </div>
        <div style={{ padding: '20px', background: 'rgba(255,255,255,0.05)', borderRadius: '16px', margin: '0 20px 20px' }}>
          <div style={{ height: '4px', background: 'rgba(255,255,255,0.2)', borderRadius: '2px', position: 'relative', marginBottom: '16px' }}>
            <div style={{ position: 'absolute', left: 0, top: 0, height: '100%', width: '75%', background: '#00D9A5', borderRadius: '2px' }} />
            <div style={{ display: 'flex', justifyContent: 'space-between', position: 'absolute', left: 0, right: 0, top: '-4px' }}>
              {[0, 1, 2, 3, 4].map(i => <div key={i} style={{ width: '12px', height: '12px', borderRadius: '50%', background: '#00D9A5', border: '2px solid #0f0f1a' }} />)}
            </div>
          </div>
          <div style={{ display: 'flex', justifyContent: 'space-between', color: 'rgba(255,255,255,0.5)', fontSize: '12px' }}>
            <span>Oct 1</span><span>Dec 24</span>
          </div>
        </div>
        <div style={{
          background: 'linear-gradient(135deg, rgba(168,85,247,0.2), rgba(99,102,241,0.2))',
          border: '1px solid rgba(168,85,247,0.3)', borderRadius: '16px', padding: '16px', margin: '0 20px 20px',
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: '#A855F7', fontSize: '12px', fontWeight: 600, marginBottom: '8px' }}>✨ AI Insight</div>
          <div style={{ color: '#fff', fontSize: '15px', lineHeight: 1.5 }}>You've gained +26° in your forward fold over 12 weeks. You're in the top 15% of improvers!</div>
        </div>
        <button style={{
          margin: '0 20px 40px', background: 'rgba(255,255,255,0.1)', border: '1px solid rgba(255,255,255,0.2)',
          color: '#fff', padding: '16px', borderRadius: '16px', fontSize: '16px', fontWeight: 500,
          textAlign: 'center', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px', width: 'calc(100% - 40px)',
        }}>📤 Share Progress</button>
      </div>
    </div>
  );

  const BookingModal = () => (
    <div style={styles.modalOverlay} onClick={() => setActiveModal(null)}>
      <div style={styles.modalContent} onClick={e => e.stopPropagation()}>
        <div style={{ padding: '20px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: '1px solid rgba(255,255,255,0.1)' }}>
          <span style={{ color: '#fff', fontSize: '18px', fontWeight: 600 }}>Book Session</span>
          <button onClick={() => setActiveModal(null)} style={{
            width: '32px', height: '32px', borderRadius: '50%', background: 'rgba(255,255,255,0.1)',
            display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', border: 'none', cursor: 'pointer',
          }}>✕</button>
        </div>
        <div style={{ padding: '20px' }}>
          <div style={{ display: 'flex', gap: '16px', marginBottom: '24px' }}>
            <div style={{
              width: '80px', height: '80px', borderRadius: '50%',
              background: 'linear-gradient(135deg, #00D9A5, #00B4D8)',
              display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '32px',
            }}>👩‍⚕️</div>
            <div>
              <div style={{ color: '#fff', fontSize: '20px', fontWeight: 600, display: 'flex', alignItems: 'center', gap: '8px' }}>Dr. Emily Chen <span style={{ color: '#00D9A5' }}>✓</span></div>
              <div style={{ color: 'rgba(255,255,255,0.5)', fontSize: '14px', marginTop: '4px' }}>DPT, Orthopedic Specialist</div>
              <div style={{ color: '#F59E0B', fontSize: '14px', marginTop: '8px' }}>⭐ 4.9 (127 reviews)</div>
            </div>
          </div>
          <div style={styles.h3}>Available Times</div>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '10px', margin: '16px 0 24px' }}>
            {[['9:00 AM', 'Tomorrow'], ['2:00 PM', 'Tomorrow', true], ['4:30 PM', 'Tomorrow'], ['10:00 AM', 'Dec 26'], ['1:00 PM', 'Dec 26'], ['3:30 PM', 'Dec 26']].map(([time, date, selected]) => (
              <div key={time + date} style={{
                background: selected ? '#00D9A5' : 'rgba(255,255,255,0.08)',
                border: `1px solid ${selected ? '#00D9A5' : 'rgba(255,255,255,0.1)'}`,
                borderRadius: '12px', padding: '14px', textAlign: 'center', cursor: 'pointer',
              }}>
                <div style={{ color: selected ? '#000' : '#fff', fontSize: '15px', fontWeight: 600 }}>{time}</div>
                <div style={{ color: selected ? 'rgba(0,0,0,0.6)' : 'rgba(255,255,255,0.5)', fontSize: '12px', marginTop: '4px' }}>{date}</div>
              </div>
            ))}
          </div>
          <div style={{
            display: 'flex', justifyContent: 'space-between', alignItems: 'center',
            padding: '16px', background: 'rgba(255,255,255,0.05)', borderRadius: '12px', marginBottom: '24px',
          }}>
            <div>
              <div style={{ color: 'rgba(255,255,255,0.6)', fontSize: '14px' }}>Session Price</div>
              <div style={{ color: 'rgba(255,255,255,0.5)', fontSize: '13px' }}>45 minutes</div>
            </div>
            <div style={{ color: '#00D9A5', fontSize: '24px', fontWeight: 700 }}>$85</div>
          </div>
          <button style={styles.btn}>Book Session</button>
        </div>
      </div>
    </div>
  );

  const ProviderSignupModal = () => (
    <div style={styles.modalOverlay} onClick={() => setActiveModal(null)}>
      <div style={styles.modalFullscreen} onClick={e => e.stopPropagation()}>
        <div style={{ padding: '60px 20px 20px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <span style={{ color: '#fff', fontSize: '20px', fontWeight: 600 }}>Become a Provider</span>
          <button onClick={() => { setActiveModal(null); setSignupStep(1); }} style={{
            width: '36px', height: '36px', borderRadius: '50%', background: 'rgba(255,255,255,0.1)',
            display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', border: 'none', cursor: 'pointer',
          }}>✕</button>
        </div>
        <div style={{ display: 'flex', gap: '8px', padding: '0 20px', marginBottom: '32px' }}>
          {[1, 2, 3, 4, 5].map(i => (
            <div key={i} style={{ flex: 1, height: '4px', background: i <= signupStep ? '#00D9A5' : 'rgba(255,255,255,0.2)', borderRadius: '2px' }} />
          ))}
        </div>
        <div style={{ padding: '0 20px' }}>
          {signupStep === 1 && (
            <>
              <div style={{ color: '#fff', fontSize: '24px', fontWeight: 700, marginBottom: '12px' }}>Share Your Expertise 🎓</div>
              <div style={{ color: 'rgba(255,255,255,0.6)', fontSize: '15px', marginBottom: '32px' }}>Join our network of verified providers and start earning.</div>
              <div style={{
                background: 'linear-gradient(135deg, #00D9A5, #00B4D8)', borderRadius: '20px',
                padding: '32px', textAlign: 'center', marginBottom: '32px',
              }}>
                <div style={{ color: '#000', fontSize: '48px', fontWeight: 800 }}>$0.30</div>
                <div style={{ color: 'rgba(0,0,0,0.6)', fontSize: '16px' }}>per 100 views</div>
              </div>
              <div style={{ marginBottom: '32px' }}>
                {['Valid license or certification', 'Professional liability insurance', 'Background check consent', '24-48 hour verification'].map(r => (
                  <div key={r} style={{ display: 'flex', alignItems: 'center', gap: '12px', color: 'rgba(255,255,255,0.8)', fontSize: '15px', marginBottom: '12px' }}>
                    <span style={{ color: '#00D9A5', fontSize: '20px' }}>✓</span> {r}
                  </div>
                ))}
              </div>
            </>
          )}
          {signupStep === 2 && (
            <>
              <div style={{ color: '#fff', fontSize: '24px', fontWeight: 700, marginBottom: '12px' }}>What type of provider are you?</div>
              <div style={{ color: 'rgba(255,255,255,0.6)', fontSize: '15px', marginBottom: '32px' }}>Select your primary certification</div>
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: '12px', marginBottom: '32px' }}>
                {[['👩‍⚕️', 'PT / DPT'], ['🧘', 'Stretch Therapist'], ['🧘‍♀️', 'Yoga Instructor'], ['💪', 'Personal Trainer'], ['💆', 'Massage Therapist'], ['🏃', 'Other']].map(([icon, name]) => (
                  <button key={name} style={{
                    background: 'rgba(255,255,255,0.05)', border: '2px solid rgba(255,255,255,0.1)',
                    borderRadius: '16px', padding: '20px 16px', textAlign: 'center', cursor: 'pointer',
                  }}>
                    <div style={{ fontSize: '32px', marginBottom: '8px' }}>{icon}</div>
                    <div style={{ color: '#fff', fontSize: '14px', fontWeight: 500 }}>{name}</div>
                  </button>
                ))}
              </div>
            </>
          )}
          {signupStep >= 3 && signupStep <= 5 && (
            <>
              <div style={{ color: '#fff', fontSize: '24px', fontWeight: 700, marginBottom: '12px' }}>
                {signupStep === 3 && 'Enter your credentials'}
                {signupStep === 4 && 'Upload documents'}
                {signupStep === 5 && 'Complete your profile'}
              </div>
              <div style={{ color: 'rgba(255,255,255,0.6)', fontSize: '15px', marginBottom: '32px' }}>
                {signupStep === 3 && "We'll verify this information"}
                {signupStep === 4 && 'Required for verification'}
                {signupStep === 5 && 'This is what patients will see'}
              </div>
              {signupStep === 3 && ['License Number', 'State', 'NPI (optional)', 'Years Experience'].map(label => (
                <div key={label} style={{ marginBottom: '20px' }}>
                  <label style={{ color: 'rgba(255,255,255,0.8)', fontSize: '14px', marginBottom: '8px', display: 'block' }}>{label}</label>
                  <input style={{
                    width: '100%', background: 'rgba(255,255,255,0.08)', border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '12px', padding: '14px 16px', color: '#fff', fontSize: '16px', outline: 'none', boxSizing: 'border-box',
                  }} />
                </div>
              ))}
              {signupStep === 4 && ['License Photo', 'Government ID', 'Insurance Certificate'].map(label => (
                <div key={label} style={{
                  border: '2px dashed rgba(255,255,255,0.2)', borderRadius: '16px',
                  padding: '32px', textAlign: 'center', cursor: 'pointer', marginBottom: '16px',
                }}>
                  <div style={{ fontSize: '40px', marginBottom: '12px' }}>📄</div>
                  <div style={{ color: 'rgba(255,255,255,0.6)', fontSize: '14px' }}>{label}</div>
                </div>
              ))}
              {signupStep === 5 && (
                <>
                  <div style={{
                    width: '120px', height: '120px', borderRadius: '50%',
                    border: '2px dashed rgba(255,255,255,0.2)', margin: '0 auto 24px',
                    display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', cursor: 'pointer',
                  }}>
                    <span style={{ fontSize: '40px' }}>📷</span>
                    <span style={{ color: 'rgba(255,255,255,0.6)', fontSize: '12px' }}>Photo</span>
                  </div>
                  <div style={{ marginBottom: '20px' }}>
                    <label style={{ color: 'rgba(255,255,255,0.8)', fontSize: '14px', marginBottom: '8px', display: 'block' }}>Professional Bio</label>
                    <input placeholder="Tell patients about yourself..." style={{
                      width: '100%', background: 'rgba(255,255,255,0.08)', border: '1px solid rgba(255,255,255,0.1)',
                      borderRadius: '12px', padding: '14px 16px', color: '#fff', fontSize: '16px', outline: 'none', boxSizing: 'border-box',
                    }} />
                  </div>
                </>
              )}
            </>
          )}
          <button onClick={() => signupStep < 5 ? setSignupStep(s => s + 1) : (setActiveModal(null), setSignupStep(1))} style={{ ...styles.btn, marginTop: '24px' }}>
            {signupStep === 5 ? 'Submit Application' : signupStep === 1 ? 'Get Started' : 'Continue'}
          </button>
        </div>
      </div>
    </div>
  );

  const consumerTabs = [
    { id: 'home', icon: '🏠', label: 'Home' },
    { id: 'discover', icon: '🔍', label: 'Discover' },
    { id: 'assess', icon: '📹', label: 'Assess' },
    { id: 'progress', icon: '📈', label: 'Progress' },
    { id: 'profile', icon: '👤', label: 'Profile' },
  ];

  const providerTabs = [
    { id: 'provider-dashboard', icon: '📊', label: 'Dashboard' },
    { id: 'provider-content', icon: '🎬', label: 'Content' },
    { id: 'provider-earnings', icon: '💰', label: 'Earnings' },
    { id: 'profile', icon: '👤', label: 'Profile' },
  ];

  const tabs = mode === 'provider' ? providerTabs : consumerTabs;

  const renderPage = () => {
    switch (currentTab) {
      case 'home': return <HomePage />;
      case 'discover': return <DiscoverPage />;
      case 'assess': return <AssessPage />;
      case 'progress': return <ProgressPage />;
      case 'profile': return <ProfilePage />;
      case 'provider-dashboard': return <ProviderDashboard />;
      case 'provider-content': return <ProviderContent />;
      case 'provider-earnings': return <ProviderEarnings />;
      default: return <HomePage />;
    }
  };

  return (
    <div style={styles.container}>
      <div style={styles.dynamicIsland} />
      <div style={styles.statusBar}>
        <span>9:41</span>
        <div style={{ display: 'flex', gap: '5px' }}>📶 📡 🔋</div>
      </div>

      {renderPage()}

      <div style={styles.tabBar}>
        {tabs.map(tab => (
          <TabItem
            key={tab.id}
            icon={tab.icon}
            label={tab.label}
            active={currentTab === tab.id}
            onClick={() => setCurrentTab(tab.id)}
          />
        ))}
      </div>

      {activeModal === 'routine-detail' && <RoutineDetailModal />}
      {activeModal === 'player' && <PlayerModal />}
      {activeModal === 'progress-reel' && <ProgressReelModal />}
      {activeModal === 'booking' && <BookingModal />}
      {activeModal === 'provider-signup' && <ProviderSignupModal />}
      {activeModal === 'category' && (
        <div style={styles.modalOverlay} onClick={() => setActiveModal(null)}>
          <div style={styles.modalContent} onClick={e => e.stopPropagation()}>
            <div style={{ padding: '20px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: '1px solid rgba(255,255,255,0.1)' }}>
              <span style={{ color: '#fff', fontSize: '18px', fontWeight: 600 }}>💻 Desk Worker</span>
              <button onClick={() => setActiveModal(null)} style={{
                width: '32px', height: '32px', borderRadius: '50%', background: 'rgba(255,255,255,0.1)',
                display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', border: 'none', cursor: 'pointer',
              }}>✕</button>
            </div>
            <div style={{ padding: '20px' }}>
              <p style={{ color: 'rgba(255,255,255,0.7)', fontSize: '14px', marginBottom: '20px' }}>12 routines designed to combat the effects of sitting all day</p>
              <RoutineCard icon="💻" title="Desk Worker Relief" desc="Full body tension release" duration="15 min" rating="4.9" onClick={() => setActiveModal('routine-detail')} />
              <RoutineCard icon="🙆" title="Posture Reset" desc="Realign your spine" duration="10 min" rating="4.8" onClick={() => setActiveModal('routine-detail')} />
              <RoutineCard icon="👐" title="Wrist & Hand Relief" desc="For keyboard warriors" duration="5 min" rating="4.7" onClick={() => setActiveModal('routine-detail')} />
            </div>
          </div>
        </div>
      )}
      {activeModal === 'assess' && (
        <div style={styles.modalOverlay} onClick={() => setActiveModal(null)}>
          <div style={styles.modalFullscreen} onClick={e => e.stopPropagation()}>
            <div style={{ padding: '60px 20px 20px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ color: '#fff', fontSize: '20px', fontWeight: 600 }}>New Assessment</span>
              <button onClick={() => setActiveModal(null)} style={{
                width: '36px', height: '36px', borderRadius: '50%', background: 'rgba(255,255,255,0.1)',
                display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', border: 'none', cursor: 'pointer',
              }}>✕</button>
            </div>
            <div style={{ padding: '24px 20px' }}>
              <div style={{ color: '#fff', fontSize: '24px', fontWeight: 700, marginBottom: '12px' }}>What's bothering you?</div>
              <div style={{ color: 'rgba(255,255,255,0.6)', fontSize: '15px', marginBottom: '24px' }}>Describe your pain so our AI can recommend the right tests</div>
              <input placeholder="e.g., My lower back hurts when I sit..." style={{
                width: '100%', background: 'rgba(255,255,255,0.08)', border: '1px solid rgba(255,255,255,0.1)',
                borderRadius: '16px', padding: '16px', color: '#fff', fontSize: '16px', marginBottom: '16px', outline: 'none', boxSizing: 'border-box',
              }} />
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px', marginBottom: '24px' }}>
                {['Low back pain', 'Hip tightness', 'Shoulder issues', 'Neck stiffness'].map(pill => (
                  <Pill key={pill} label={pill} active={selectedPills.includes(pill)} onClick={() => togglePill(pill)} />
                ))}
              </div>
              <div style={{
                background: 'linear-gradient(135deg, rgba(168,85,247,0.2), rgba(99,102,241,0.2))',
                border: '1px solid rgba(168,85,247,0.3)', borderRadius: '16px', padding: '16px', marginBottom: '24px',
              }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: '#A855F7', fontSize: '12px', fontWeight: 600, marginBottom: '8px' }}>✨ AI Recommendation</div>
                <div style={{ color: '#fff', fontSize: '15px', lineHeight: 1.5 }}>Based on your input, I recommend starting with a <strong>Forward Fold Test</strong> to assess your flexibility.</div>
              </div>
              <button style={{
                background: 'linear-gradient(135deg, #00D9A5, #00B4D8)', borderRadius: '24px',
                padding: '32px 24px', textAlign: 'center', cursor: 'pointer', border: 'none', width: '100%',
              }}>
                <div style={{ fontSize: '48px', marginBottom: '16px' }}>📹</div>
                <div style={{ color: '#000', fontSize: '20px', fontWeight: 600, marginBottom: '8px' }}>Start Recording</div>
                <div style={{ color: 'rgba(0,0,0,0.7)', fontSize: '14px' }}>Position your phone and we'll guide you through</div>
              </button>
            </div>
          </div>
        </div>
      )}
      {activeModal === 'content-studio' && (
        <div style={styles.modalOverlay} onClick={() => setActiveModal(null)}>
          <div style={styles.modalFullscreen} onClick={e => e.stopPropagation()}>
            <div style={{ padding: '60px 20px 20px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ color: '#fff', fontSize: '20px', fontWeight: 600 }}>Content Studio</span>
              <button onClick={() => setActiveModal(null)} style={{
                width: '36px', height: '36px', borderRadius: '50%', background: 'rgba(255,255,255,0.1)',
                display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', border: 'none', cursor: 'pointer',
              }}>✕</button>
            </div>
            <div style={{ padding: '24px 20px' }}>
              <div style={{ color: '#fff', fontSize: '24px', fontWeight: 700, marginBottom: '12px' }}>Upload Your Routine</div>
              <div style={{ color: 'rgba(255,255,255,0.6)', fontSize: '15px', marginBottom: '24px' }}>Share your expertise with thousands of users</div>
              <div style={{
                border: '2px dashed rgba(255,255,255,0.2)', borderRadius: '16px',
                padding: '48px', textAlign: 'center', cursor: 'pointer', marginBottom: '24px',
              }}>
                <div style={{ fontSize: '40px', marginBottom: '12px' }}>🎬</div>
                <div style={{ color: 'rgba(255,255,255,0.6)', fontSize: '14px' }}>Tap to upload video</div>
              </div>
              <div style={{ color: '#fff', fontSize: '16px', fontWeight: 600, marginBottom: '12px' }}>Tips for great content:</div>
              {['Good lighting and clear audio', 'Show movements from multiple angles', 'Include clear instructions', '5-20 minutes optimal length'].map(tip => (
                <div key={tip} style={{ display: 'flex', alignItems: 'center', gap: '12px', color: 'rgba(255,255,255,0.8)', fontSize: '15px', marginBottom: '12px' }}>
                  <span style={{ color: '#00D9A5' }}>💡</span> {tip}
                </div>
              ))}
              <div style={{
                background: 'linear-gradient(135deg, #00D9A5, #00B4D8)', borderRadius: '20px',
                padding: '32px', textAlign: 'center', margin: '24px 0',
              }}>
                <div style={{ color: '#000', fontSize: '48px', fontWeight: 800 }}>$0.30</div>
                <div style={{ color: 'rgba(0,0,0,0.6)', fontSize: '16px' }}>per 100 views</div>
              </div>
              <button style={styles.btn}>Continue to Details</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
