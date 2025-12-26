import React, { useState } from 'react';

// SVG Icons as components
const Icons = {
  Home: () => <svg width="24" height="24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>,
  Search: () => <svg width="24" height="24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>,
  User: () => <svg width="24" height="24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>,
  Play: () => <svg width="24" height="24" fill="currentColor" viewBox="0 0 24 24"><polygon points="5 3 19 12 5 21 5 3"/></svg>,
  Clock: () => <svg width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="8" cy="8" r="7"/><polyline points="8 4 8 8 11 10"/></svg>,
  Star: () => <svg width="16" height="16" fill="currentColor" stroke="currentColor" strokeWidth="1" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>,
  Check: () => <svg width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><polyline points="20 6 9 17 4 12"/></svg>,
  ChevronRight: () => <svg width="20" height="20" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="9 18 15 12 9 6"/></svg>,
  Calendar: () => <svg width="20" height="20" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>,
  Heart: () => <svg width="20" height="20" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>,
  X: () => <svg width="24" height="24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>,
  Pause: () => <svg width="32" height="32" fill="currentColor" viewBox="0 0 24 24"><rect x="6" y="4" width="4" height="16"/><rect x="14" y="4" width="4" height="16"/></svg>,
  SkipBack: () => <svg width="24" height="24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polygon points="19 20 9 12 19 4 19 20"/><line x1="5" y1="19" x2="5" y2="5"/></svg>,
  SkipForward: () => <svg width="24" height="24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polygon points="5 4 15 12 5 20 5 4"/><line x1="19" y1="5" x2="19" y2="19"/></svg>,
  Grid: () => <svg width="20" height="20" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>,
  Bookmark: () => <svg width="20" height="20" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg>,
  Settings: () => <svg width="20" height="20" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>,
  Bell: () => <svg width="20" height="20" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>,
  Award: () => <svg width="20" height="20" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="8" r="7"/><polyline points="8.21 13.89 7 23 12 20 17 23 15.79 13.88"/></svg>,
  Layers: () => <svg width="20" height="20" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polygon points="12 2 2 7 12 12 22 7 12 2"/><polyline points="2 17 12 22 22 17"/><polyline points="2 12 12 17 22 12"/></svg>,
};

// Color palette - White background with sophisticated grey and sage highlights
const colors = {
  // Sage palette - muted, sophisticated
  sage: '#8FA89A',
  sageDark: '#6B8577',
  sageLight: '#F2F7F4',
  sageMuted: '#A8BDB2',
  // Pure white base
  white: '#FFFFFF',
  // Sophisticated grey scale
  grey50: '#FCFCFC',
  grey100: '#F8F8F8',
  grey150: '#F3F3F3',
  grey200: '#EBEBEB',
  grey300: '#DEDEDE',
  grey400: '#C4C4C4',
  grey500: '#9E9E9E',
  grey600: '#757575',
  grey700: '#5C5C5C',
  grey800: '#3D3D3D',
  grey900: '#1A1A1A',
};

// Wellness image placeholders - subtle grey and sage gradients
const wellnessImages = [
  'linear-gradient(145deg, #F2F7F4 0%, #E5EDE9 100%)', // sage tint
  'linear-gradient(145deg, #F5F5F5 0%, #EBEBEB 100%)', // pure grey
  'linear-gradient(145deg, #EFF4F1 0%, #E2EBE6 100%)', // sage muted
  'linear-gradient(145deg, #F7F7F7 0%, #EDEDED 100%)', // light grey
  'linear-gradient(145deg, #F4F8F6 0%, #E8F0EC 100%)', // sage light
  'linear-gradient(145deg, #F3F3F3 0%, #E8E8E8 100%)', // warm grey
];

export default function FlekksApp() {
  const [currentTab, setCurrentTab] = useState('home');
  const [activeModal, setActiveModal] = useState(null);
  const [selectedRoutine, setSelectedRoutine] = useState(null);
  const [selectedProvider, setSelectedProvider] = useState(null);
  const [selectedCategory, setSelectedCategory] = useState(null);
  const [savedRoutines, setSavedRoutines] = useState([]);
  const [selectedTimeSlot, setSelectedTimeSlot] = useState('2:00 PM');
  const [profileTab, setProfileTab] = useState('progress');

  const toggleSave = (id) => {
    setSavedRoutines(prev =>
      prev.includes(id) ? prev.filter(r => r !== id) : [...prev, id]
    );
  };

  const routines = [
    { id: 1, title: 'Morning Stretch Flow', provider: 'Dr. Sarah Chen', duration: '15 min', rating: 4.9, reviews: 2847, category: 'morning', image: wellnessImages[0], completions: '18.2k' },
    { id: 2, title: 'Desk Worker Relief', provider: 'Marcus Thompson', duration: '12 min', rating: 4.8, reviews: 1923, category: 'desk', image: wellnessImages[1], completions: '24.1k' },
    { id: 3, title: 'Hip Opener Sequence', provider: 'Dr. Emily Park', duration: '20 min', rating: 4.9, reviews: 3156, category: 'hips', image: wellnessImages[2], completions: '15.7k' },
    { id: 4, title: 'Shoulder & Neck Release', provider: 'James Wilson', duration: '10 min', rating: 4.7, reviews: 1456, category: 'upper', image: wellnessImages[3], completions: '21.3k' },
    { id: 5, title: 'Lower Back Restore', provider: 'Dr. Lisa Martinez', duration: '18 min', rating: 4.9, reviews: 2234, category: 'back', image: wellnessImages[4], completions: '19.8k' },
    { id: 6, title: 'Full Body Mobility', provider: 'Alex Rivera', duration: '25 min', rating: 4.8, reviews: 1876, category: 'full', image: wellnessImages[5], completions: '12.4k' },
    { id: 7, title: 'Pre-Workout Activation', provider: 'Dr. Sarah Chen', duration: '8 min', rating: 4.6, reviews: 987, category: 'workout', image: wellnessImages[0], completions: '8.9k' },
    { id: 8, title: 'Post-Run Recovery', provider: 'Marcus Thompson', duration: '15 min', rating: 4.8, reviews: 1654, category: 'recovery', image: wellnessImages[1], completions: '11.2k' },
    { id: 9, title: 'Evening Wind Down', provider: 'Dr. Emily Park', duration: '20 min', rating: 4.9, reviews: 2341, category: 'evening', image: wellnessImages[2], completions: '16.5k' },
    { id: 10, title: 'Spinal Decompression', provider: 'Dr. Lisa Martinez', duration: '12 min', rating: 4.7, reviews: 1123, category: 'back', image: wellnessImages[4], completions: '9.3k' },
  ];

  const providers = [
    { id: 1, name: 'Dr. Sarah Chen', title: 'DPT, Orthopedic Specialist', rating: 4.9, reviews: 234, price: 95, available: 'Tomorrow', image: wellnessImages[0], specialties: ['Back Pain', 'Sports Rehab', 'Posture'] },
    { id: 2, name: 'Marcus Thompson', title: 'Certified Stretch Therapist', rating: 4.8, reviews: 189, price: 75, available: 'Today', image: wellnessImages[1], specialties: ['Flexibility', 'Athletes', 'Recovery'] },
    { id: 3, name: 'Dr. Emily Park', title: 'Physical Therapist, RYT-500', rating: 4.9, reviews: 312, price: 110, available: 'Tomorrow', image: wellnessImages[2], specialties: ['Hip Mobility', 'Yoga Therapy', 'Chronic Pain'] },
    { id: 4, name: 'James Wilson', title: 'Licensed Massage Therapist', rating: 4.7, reviews: 156, price: 85, available: 'Wed', image: wellnessImages[3], specialties: ['Deep Tissue', 'Trigger Points', 'Relaxation'] },
    { id: 5, name: 'Dr. Lisa Martinez', title: 'Chiropractor, CSCS', rating: 4.9, reviews: 278, price: 120, available: 'Today', image: wellnessImages[4], specialties: ['Spinal Health', 'Strength', 'Ergonomics'] },
    { id: 6, name: 'Alex Rivera', title: 'Personal Trainer, FMS', rating: 4.8, reviews: 145, price: 70, available: 'Tomorrow', image: wellnessImages[5], specialties: ['Movement', 'Corrective Exercise', 'Fitness'] },
  ];

  const categories = [
    { id: 'desk', name: 'Desk Worker', count: 24, image: wellnessImages[0] },
    { id: 'morning', name: 'Morning Routines', count: 18, image: wellnessImages[1] },
    { id: 'back', name: 'Back Relief', count: 31, image: wellnessImages[2] },
    { id: 'hips', name: 'Hip Mobility', count: 22, image: wellnessImages[3] },
    { id: 'recovery', name: 'Recovery', count: 27, image: wellnessImages[4] },
    { id: 'sleep', name: 'Better Sleep', count: 15, image: wellnessImages[5] },
  ];

  const progressStacks = [
    { id: 1, name: 'Forward Fold', count: 12, thumbnail: wellnessImages[0], improvement: '+24°' },
    { id: 2, name: 'Deep Squat', count: 8, thumbnail: wellnessImages[1], improvement: '+18°' },
    { id: 3, name: 'Hip 90/90', count: 15, thumbnail: wellnessImages[2], improvement: '+31°' },
    { id: 4, name: 'Shoulder Reach', count: 6, thumbnail: wellnessImages[3], improvement: '+12°' },
    { id: 5, name: 'Spinal Twist', count: 9, thumbnail: wellnessImages[4], improvement: '+15°' },
    { id: 6, name: 'Hamstring', count: 11, thumbnail: wellnessImages[5], improvement: '+22°' },
  ];

  const styles = {
    container: {
      width: '100%',
      maxWidth: '390px',
      height: '844px',
      background: colors.white,
      borderRadius: '44px',
      overflow: 'hidden',
      position: 'relative',
      fontFamily: '-apple-system, BlinkMacSystemFont, "SF Pro Display", sans-serif',
      margin: '0 auto',
      boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.12)',
    },
    dynamicIsland: {
      position: 'absolute',
      top: '12px',
      left: '50%',
      transform: 'translateX(-50%)',
      width: '126px',
      height: '37px',
      background: colors.grey900,
      borderRadius: '20px',
      zIndex: 1000,
    },
    statusBar: {
      height: '54px',
      padding: '14px 28px 0',
      display: 'flex',
      justifyContent: 'space-between',
      alignItems: 'flex-start',
      color: colors.grey800,
      fontSize: '14px',
      fontWeight: 600,
    },
    page: {
      height: 'calc(100% - 54px - 80px)',
      overflowY: 'auto',
      background: colors.white,
    },
    tabBar: {
      position: 'absolute',
      bottom: 0,
      left: 0,
      right: 0,
      height: '80px',
      background: colors.white,
      borderTop: `1px solid ${colors.grey150}`,
      display: 'flex',
      justifyContent: 'space-around',
      alignItems: 'flex-start',
      paddingTop: '12px',
    },
  };

  // Components
  const TabItem = ({ icon: Icon, label, active, onClick }) => (
    <button onClick={onClick} style={{
      display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '4px',
      background: 'none', border: 'none', cursor: 'pointer', padding: 0,
    }}>
      <div style={{ color: active ? colors.sage : colors.grey400 }}><Icon /></div>
      <span style={{ fontSize: '10px', fontWeight: 500, color: active ? colors.sage : colors.grey500 }}>{label}</span>
    </button>
  );

  const SectionHeader = ({ title, action, onAction }) => (
    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '20px 20px 12px' }}>
      <h2 style={{ fontSize: '18px', fontWeight: 700, color: colors.grey900, margin: 0 }}>{title}</h2>
      {action && (
        <button onClick={onAction} style={{ background: 'none', border: 'none', color: colors.sage, fontSize: '14px', fontWeight: 600, cursor: 'pointer' }}>
          {action}
        </button>
      )}
    </div>
  );

  const RoutineCard = ({ routine, size = 'normal' }) => (
    <button onClick={() => { setSelectedRoutine(routine); setActiveModal('routine'); }} style={{
      background: colors.white,
      borderRadius: '14px',
      overflow: 'hidden',
      border: `1px solid ${colors.grey150}`,
      cursor: 'pointer',
      textAlign: 'left',
      width: size === 'large' ? '100%' : size === 'small' ? '140px' : '280px',
      flexShrink: 0,
      boxShadow: '0 1px 3px rgba(0,0,0,0.04)',
    }}>
      <div style={{
        height: size === 'large' ? '180px' : size === 'small' ? '100px' : '140px',
        background: routine.image,
        position: 'relative',
      }}>
        <div style={{
          position: 'absolute', bottom: '12px', left: '12px',
          background: 'rgba(255,255,255,0.95)', padding: '6px 10px', borderRadius: '8px',
          display: 'flex', alignItems: 'center', gap: '4px',
        }}>
          <span style={{ color: colors.grey600 }}><Icons.Clock /></span>
          <span style={{ fontSize: '12px', fontWeight: 600, color: colors.grey700 }}>{routine.duration}</span>
        </div>
        <button onClick={(e) => { e.stopPropagation(); toggleSave(routine.id); }} style={{
          position: 'absolute', top: '12px', right: '12px',
          background: 'rgba(255,255,255,0.95)', border: 'none', borderRadius: '50%',
          width: '32px', height: '32px', display: 'flex', alignItems: 'center', justifyContent: 'center',
          cursor: 'pointer', color: savedRoutines.includes(routine.id) ? colors.sage : colors.grey400,
        }}>
          <Icons.Bookmark />
        </button>
      </div>
      <div style={{ padding: '14px' }}>
        <h3 style={{ fontSize: size === 'small' ? '13px' : '15px', fontWeight: 600, color: colors.grey900, margin: '0 0 4px' }}>{routine.title}</h3>
        <p style={{ fontSize: '12px', color: colors.grey500, margin: '0 0 8px' }}>{routine.provider}</p>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '3px' }}>
            <span style={{ color: '#F59E0B' }}><Icons.Star /></span>
            <span style={{ fontSize: '12px', fontWeight: 600, color: colors.grey700 }}>{routine.rating}</span>
          </div>
          <span style={{ fontSize: '12px', color: colors.grey400 }}>({routine.reviews.toLocaleString()})</span>
        </div>
      </div>
    </button>
  );

  const ProviderCard = ({ provider }) => (
    <button onClick={() => { setSelectedProvider(provider); setActiveModal('booking'); }} style={{
      background: colors.white,
      borderRadius: '14px',
      padding: '16px',
      border: `1px solid ${colors.grey150}`,
      cursor: 'pointer',
      textAlign: 'left',
      width: '100%',
      display: 'flex',
      gap: '14px',
      alignItems: 'center',
      boxShadow: '0 1px 3px rgba(0,0,0,0.04)',
      marginBottom: '12px',
    }}>
      <div style={{
        width: '64px', height: '64px', borderRadius: '50%',
        background: provider.image, flexShrink: 0,
        border: `3px solid ${colors.sageLight}`,
      }} />
      <div style={{ flex: 1 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '6px', marginBottom: '2px' }}>
          <h3 style={{ fontSize: '15px', fontWeight: 600, color: colors.grey900, margin: 0 }}>{provider.name}</h3>
          <span style={{ color: colors.sage }}><Icons.Check /></span>
        </div>
        <p style={{ fontSize: '13px', color: colors.grey500, margin: '0 0 6px' }}>{provider.title}</p>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '3px' }}>
            <span style={{ color: '#F59E0B' }}><Icons.Star /></span>
            <span style={{ fontSize: '12px', fontWeight: 600, color: colors.grey700 }}>{provider.rating}</span>
          </div>
          <span style={{ fontSize: '13px', color: colors.sage, fontWeight: 600 }}>${provider.price}/session</span>
        </div>
      </div>
      <div style={{ color: colors.grey300 }}><Icons.ChevronRight /></div>
    </button>
  );

  const CategoryCard = ({ category }) => (
    <button onClick={() => { setSelectedCategory(category); setActiveModal('category'); }} style={{
      background: colors.grey50,
      borderRadius: '12px',
      padding: '18px 16px',
      border: `1px solid ${colors.grey150}`,
      cursor: 'pointer',
      textAlign: 'left',
      position: 'relative',
      overflow: 'hidden',
    }}>
      <h3 style={{ fontSize: '14px', fontWeight: 600, color: colors.grey800, margin: '0 0 4px' }}>{category.name}</h3>
      <p style={{ fontSize: '12px', color: colors.grey500, margin: 0 }}>{category.count} routines</p>
    </button>
  );

  const ProgressStack = ({ stack }) => (
    <button onClick={() => setActiveModal('progress-stack')} style={{
      background: 'none', border: 'none', cursor: 'pointer', padding: 0, textAlign: 'center',
    }}>
      <div style={{ position: 'relative', width: '100%', aspectRatio: '1', marginBottom: '8px' }}>
        {/* Stacked effect */}
        <div style={{
          position: 'absolute', top: '4px', left: '4px', right: '-4px', bottom: '-4px',
          background: colors.grey200, borderRadius: '10px', transform: 'rotate(3deg)',
        }} />
        <div style={{
          position: 'absolute', top: '2px', left: '2px', right: '-2px', bottom: '-2px',
          background: colors.grey150, borderRadius: '10px', transform: 'rotate(1.5deg)',
        }} />
        <div style={{
          position: 'relative', width: '100%', height: '100%',
          background: colors.grey50, borderRadius: '10px',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          border: `1px solid ${colors.grey150}`,
        }}>
          <div style={{
            background: colors.white, padding: '4px 8px', borderRadius: '6px',
            fontSize: '11px', fontWeight: 600, color: colors.sage,
            border: `1px solid ${colors.grey150}`,
          }}>
            {stack.count} videos
          </div>
        </div>
      </div>
      <p style={{ fontSize: '12px', fontWeight: 500, color: colors.grey700, margin: '0 0 2px' }}>{stack.name}</p>
      <p style={{ fontSize: '11px', fontWeight: 600, color: colors.sage, margin: 0 }}>{stack.improvement}</p>
    </button>
  );

  // Pages
  const HomePage = () => (
    <div style={styles.page}>
      {/* Header */}
      <div style={{ background: colors.white, padding: '20px 20px 16px' }}>
        <p style={{ fontSize: '13px', color: colors.grey500, margin: '0 0 4px', letterSpacing: '0.3px' }}>Good morning</p>
        <h1 style={{ fontSize: '26px', fontWeight: 700, color: colors.grey900, margin: 0, letterSpacing: '-0.5px' }}>Find your flow</h1>
      </div>

      {/* Featured */}
      <div style={{ padding: '20px' }}>
        <RoutineCard routine={routines[0]} size="large" />
      </div>

      {/* Categories */}
      <SectionHeader title="Browse by Goal" action="See all" onAction={() => setCurrentTab('discover')} />
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: '12px', padding: '0 20px 20px' }}>
        {categories.slice(0, 4).map(cat => <CategoryCard key={cat.id} category={cat} />)}
      </div>

      {/* Popular Routines */}
      <SectionHeader title="Popular Routines" action="See all" onAction={() => setCurrentTab('discover')} />
      <div style={{ display: 'flex', gap: '12px', padding: '0 20px 20px', overflowX: 'auto' }}>
        {routines.slice(1, 5).map(routine => <RoutineCard key={routine.id} routine={routine} />)}
      </div>

      {/* Quick Relief */}
      <SectionHeader title="Quick Relief (Under 10 min)" />
      <div style={{ display: 'flex', gap: '12px', padding: '0 20px 20px', overflowX: 'auto' }}>
        {routines.filter(r => parseInt(r.duration) <= 10).map(routine => <RoutineCard key={routine.id} routine={routine} size="small" />)}
      </div>

      {/* Top Specialists */}
      <SectionHeader title="Top Specialists" action="See all" onAction={() => setCurrentTab('discover')} />
      <div style={{ padding: '0 20px 100px' }}>
        {providers.slice(0, 3).map(provider => <ProviderCard key={provider.id} provider={provider} />)}
      </div>
    </div>
  );

  const DiscoverPage = () => (
    <div style={styles.page}>
      {/* Search */}
      <div style={{ padding: '20px', background: colors.white }}>
        <div style={{
          background: colors.grey50, borderRadius: '12px', padding: '12px 16px',
          display: 'flex', alignItems: 'center', gap: '10px',
          border: `1px solid ${colors.grey150}`,
        }}>
          <span style={{ color: colors.grey400 }}><Icons.Search /></span>
          <input placeholder="Search routines or specialists..." style={{
            background: 'none', border: 'none', fontSize: '15px', color: colors.grey800,
            width: '100%', outline: 'none',
          }} />
        </div>
      </div>

      {/* All Categories */}
      <SectionHeader title="Categories" />
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: '12px', padding: '0 20px 20px' }}>
        {categories.map(cat => <CategoryCard key={cat.id} category={cat} />)}
      </div>

      {/* All Specialists */}
      <SectionHeader title="Book a Specialist" />
      <div style={{ padding: '0 20px 20px' }}>
        {providers.map(provider => <ProviderCard key={provider.id} provider={provider} />)}
      </div>

      {/* All Routines */}
      <SectionHeader title="All Routines" />
      <div style={{ padding: '0 20px 100px' }}>
        {routines.map(routine => (
          <div key={routine.id} style={{ marginBottom: '12px' }}>
            <RoutineCard routine={routine} size="large" />
          </div>
        ))}
      </div>
    </div>
  );

  const ProfilePage = () => (
    <div style={styles.page}>
      {/* Profile Header */}
      <div style={{ background: colors.white, padding: '24px 20px', textAlign: 'center' }}>
        <div style={{
          width: '88px', height: '88px', borderRadius: '50%',
          background: colors.sageLight, margin: '0 auto 14px',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          border: `2px solid ${colors.sageMuted}`,
        }}>
          <span style={{ fontSize: '32px', fontWeight: 600, color: colors.sage }}>S</span>
        </div>
        <h1 style={{ fontSize: '20px', fontWeight: 700, color: colors.grey900, margin: '0 0 4px' }}>Sarah Mitchell</h1>
        <p style={{ fontSize: '13px', color: colors.grey500, margin: 0 }}>Member since Jan 2024</p>

        {/* Stats */}
        <div style={{ display: 'flex', justifyContent: 'center', gap: '40px', marginTop: '20px' }}>
          {[['47', 'Completed'], ['12', 'Saved'], ['8', 'Day Streak']].map(([val, label]) => (
            <div key={label}>
              <div style={{ fontSize: '20px', fontWeight: 700, color: colors.grey800 }}>{val}</div>
              <div style={{ fontSize: '12px', color: colors.grey500 }}>{label}</div>
            </div>
          ))}
        </div>
      </div>

      {/* Tab Toggle */}
      <div style={{ display: 'flex', background: colors.white, borderTop: `1px solid ${colors.grey150}`, borderBottom: `1px solid ${colors.grey150}` }}>
        {[['progress', Icons.Grid, 'Progress'], ['saved', Icons.Bookmark, 'Saved']].map(([id, Icon, label]) => (
          <button key={id} onClick={() => setProfileTab(id)} style={{
            flex: 1, padding: '14px', background: 'none', border: 'none',
            borderBottom: profileTab === id ? `2px solid ${colors.sage}` : '2px solid transparent',
            cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '6px',
          }}>
            <span style={{ color: profileTab === id ? colors.sage : colors.grey400 }}><Icon /></span>
            <span style={{ fontSize: '14px', fontWeight: 500, color: profileTab === id ? colors.sage : colors.grey500 }}>{label}</span>
          </button>
        ))}
      </div>

      {/* Progress Stacks (Instagram-style grid) */}
      {profileTab === 'progress' && (
        <div style={{ padding: '20px' }}>
          <p style={{ fontSize: '13px', color: colors.grey500, margin: '0 0 16px', textAlign: 'center' }}>
            Track your movement progress over time
          </p>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '16px' }}>
            {progressStacks.map(stack => <ProgressStack key={stack.id} stack={stack} />)}
          </div>
        </div>
      )}

      {/* Saved Routines */}
      {profileTab === 'saved' && (
        <div style={{ padding: '20px' }}>
          {savedRoutines.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '40px 20px' }}>
              <div style={{ color: colors.grey300, marginBottom: '12px' }}><Icons.Bookmark /></div>
              <p style={{ fontSize: '14px', color: colors.grey500 }}>No saved routines yet</p>
            </div>
          ) : (
            routines.filter(r => savedRoutines.includes(r.id)).map(routine => (
              <div key={routine.id} style={{ marginBottom: '12px' }}>
                <RoutineCard routine={routine} size="large" />
              </div>
            ))
          )}
        </div>
      )}

      {/* Settings */}
      <div style={{ padding: '20px', marginTop: '8px' }}>
        <h3 style={{ fontSize: '12px', fontWeight: 600, color: colors.grey500, margin: '0 0 12px', textTransform: 'uppercase', letterSpacing: '0.5px' }}>Settings</h3>
        <div style={{ background: colors.grey50, borderRadius: '12px', overflow: 'hidden', border: `1px solid ${colors.grey150}` }}>
          {[
            [Icons.Bell, 'Notifications'],
            [Icons.Award, 'Achievements'],
            [Icons.Settings, 'Preferences'],
          ].map(([Icon, label], i, arr) => (
            <button key={label} style={{
              width: '100%', padding: '15px 16px', display: 'flex', alignItems: 'center', gap: '12px',
              background: 'none', border: 'none', cursor: 'pointer', textAlign: 'left',
              borderBottom: i < arr.length - 1 ? `1px solid ${colors.grey150}` : 'none',
            }}>
              <span style={{ color: colors.grey500 }}><Icon /></span>
              <span style={{ flex: 1, fontSize: '15px', color: colors.grey700 }}>{label}</span>
              <span style={{ color: colors.grey300 }}><Icons.ChevronRight /></span>
            </button>
          ))}
        </div>
      </div>
    </div>
  );

  // Modals
  const RoutineModal = () => {
    if (!selectedRoutine) return null;
    return (
      <div style={{
        position: 'absolute', top: 0, left: 0, right: 0, bottom: 0,
        background: 'rgba(0,0,0,0.5)', zIndex: 200,
      }} onClick={() => setActiveModal(null)}>
        <div style={{
          position: 'absolute', bottom: 0, left: 0, right: 0,
          background: colors.white, borderRadius: '24px 24px 0 0',
          maxHeight: '90%', overflowY: 'auto',
        }} onClick={e => e.stopPropagation()}>
          {/* Hero Image */}
          <div style={{ height: '220px', background: selectedRoutine.image, position: 'relative' }}>
            <button onClick={() => setActiveModal(null)} style={{
              position: 'absolute', top: '16px', right: '16px',
              width: '36px', height: '36px', borderRadius: '50%',
              background: 'rgba(255,255,255,0.9)', border: 'none', cursor: 'pointer',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              color: colors.grey600,
            }}><Icons.X /></button>
            <div style={{
              position: 'absolute', bottom: '16px', left: '16px',
              background: 'rgba(255,255,255,0.95)', padding: '8px 12px', borderRadius: '10px',
              display: 'flex', alignItems: 'center', gap: '6px',
            }}>
              <span style={{ color: colors.grey600 }}><Icons.Clock /></span>
              <span style={{ fontSize: '14px', fontWeight: 600, color: colors.grey700 }}>{selectedRoutine.duration}</span>
            </div>
          </div>

          {/* Content */}
          <div style={{ padding: '24px' }}>
            <h1 style={{ fontSize: '24px', fontWeight: 700, color: colors.grey900, margin: '0 0 8px' }}>{selectedRoutine.title}</h1>

            {/* Provider */}
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '16px' }}>
              <div style={{ width: '32px', height: '32px', borderRadius: '50%', background: colors.sageLight }} />
              <span style={{ fontSize: '14px', color: colors.grey600 }}>{selectedRoutine.provider}</span>
              <span style={{ color: colors.sage }}><Icons.Check /></span>
            </div>

            {/* Stats */}
            <div style={{ display: 'flex', gap: '20px', marginBottom: '20px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                <span style={{ color: '#F59E0B' }}><Icons.Star /></span>
                <span style={{ fontSize: '14px', fontWeight: 600, color: colors.grey700 }}>{selectedRoutine.rating}</span>
                <span style={{ fontSize: '14px', color: colors.grey500 }}>({selectedRoutine.reviews.toLocaleString()} reviews)</span>
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                <span style={{ color: colors.sage }}><Icons.Check /></span>
                <span style={{ fontSize: '14px', color: colors.grey600 }}>{selectedRoutine.completions} completed</span>
              </div>
            </div>

            <p style={{ fontSize: '15px', color: colors.grey600, lineHeight: 1.6, margin: '0 0 20px' }}>
              A carefully designed routine to help release tension and improve mobility. Perfect for anyone looking to feel better in their body.
            </p>

            {/* Target Areas */}
            <h3 style={{ fontSize: '13px', fontWeight: 600, color: colors.grey700, margin: '0 0 12px', textTransform: 'uppercase', letterSpacing: '0.3px' }}>Target Areas</h3>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px', marginBottom: '24px' }}>
              {['Neck', 'Shoulders', 'Lower Back', 'Hips'].map(area => (
                <span key={area} style={{
                  background: colors.grey50, color: colors.grey700,
                  padding: '8px 14px', borderRadius: '20px', fontSize: '13px', fontWeight: 500,
                  border: `1px solid ${colors.grey200}`,
                }}>{area}</span>
              ))}
            </div>

            {/* What You'll Do */}
            <h3 style={{ fontSize: '13px', fontWeight: 600, color: colors.grey700, margin: '0 0 12px', textTransform: 'uppercase', letterSpacing: '0.3px' }}>What You'll Do</h3>
            <div style={{ marginBottom: '24px' }}>
              {['Gentle warm-up stretches', 'Targeted mobility work', 'Deep tissue release', 'Relaxation cool-down'].map((item, i) => (
                <div key={i} style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '10px' }}>
                  <span style={{ color: colors.sageMuted }}><Icons.Check /></span>
                  <span style={{ fontSize: '14px', color: colors.grey600 }}>{item}</span>
                </div>
              ))}
            </div>

            {/* CTA */}
            <button onClick={() => setActiveModal('player')} style={{
              width: '100%', background: colors.sage, color: colors.white,
              padding: '18px', borderRadius: '14px', border: 'none', cursor: 'pointer',
              fontSize: '16px', fontWeight: 600, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px',
            }}>
              <Icons.Play /> Start Routine
            </button>
          </div>
        </div>
      </div>
    );
  };

  const PlayerModal = () => {
    if (!selectedRoutine) return null;
    return (
      <div style={{
        position: 'absolute', top: 0, left: 0, right: 0, bottom: 0,
        background: colors.grey900, zIndex: 300,
      }}>
        {/* Header */}
        <div style={{ padding: '60px 20px 20px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h2 style={{ fontSize: '18px', fontWeight: 600, color: colors.white, margin: 0 }}>{selectedRoutine.title}</h2>
          <button onClick={() => setActiveModal(null)} style={{
            width: '36px', height: '36px', borderRadius: '50%',
            background: 'rgba(255,255,255,0.1)', border: 'none', cursor: 'pointer',
            display: 'flex', alignItems: 'center', justifyContent: 'center', color: colors.white,
          }}><Icons.X /></button>
        </div>

        {/* Exercise Display */}
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', padding: '60px 20px', textAlign: 'center' }}>
          <div style={{
            width: '180px', height: '180px', borderRadius: '50%',
            background: `linear-gradient(135deg, ${colors.sageLight} 0%, ${colors.sage}40 100%)`,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            marginBottom: '32px',
          }}>
            <div style={{
              width: '140px', height: '140px', borderRadius: '50%',
              background: selectedRoutine.image,
            }} />
          </div>
          <p style={{ fontSize: '14px', color: colors.grey400, margin: '0 0 8px' }}>Exercise 2 of 8</p>
          <h1 style={{ fontSize: '28px', fontWeight: 700, color: colors.white, margin: '0 0 40px' }}>Neck Circles</h1>
          <div style={{ fontSize: '64px', fontWeight: 800, color: colors.sage }}>0:24</div>
        </div>

        {/* Controls */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '40px', padding: '40px' }}>
          <button style={{
            width: '56px', height: '56px', borderRadius: '50%',
            background: 'rgba(255,255,255,0.1)', border: 'none', cursor: 'pointer',
            display: 'flex', alignItems: 'center', justifyContent: 'center', color: colors.white,
          }}><Icons.SkipBack /></button>
          <button style={{
            width: '80px', height: '80px', borderRadius: '50%',
            background: colors.sage, border: 'none', cursor: 'pointer',
            display: 'flex', alignItems: 'center', justifyContent: 'center', color: colors.white,
          }}><Icons.Pause /></button>
          <button style={{
            width: '56px', height: '56px', borderRadius: '50%',
            background: 'rgba(255,255,255,0.1)', border: 'none', cursor: 'pointer',
            display: 'flex', alignItems: 'center', justifyContent: 'center', color: colors.white,
          }}><Icons.SkipForward /></button>
        </div>

        {/* Progress */}
        <div style={{ position: 'absolute', bottom: '100px', left: '20px', right: '20px' }}>
          <div style={{ height: '4px', background: 'rgba(255,255,255,0.2)', borderRadius: '2px' }}>
            <div style={{ width: '35%', height: '100%', background: colors.sage, borderRadius: '2px' }} />
          </div>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: '8px' }}>
            <span style={{ fontSize: '12px', color: colors.grey500 }}>2:45</span>
            <span style={{ fontSize: '12px', color: colors.grey500 }}>{selectedRoutine.duration}</span>
          </div>
        </div>
      </div>
    );
  };

  const BookingModal = () => {
    if (!selectedProvider) return null;
    const timeSlots = [
      { time: '9:00 AM', date: 'Tomorrow' },
      { time: '11:30 AM', date: 'Tomorrow' },
      { time: '2:00 PM', date: 'Tomorrow' },
      { time: '4:30 PM', date: 'Tomorrow' },
      { time: '10:00 AM', date: 'Wed, Jan 3' },
      { time: '1:00 PM', date: 'Wed, Jan 3' },
    ];
    return (
      <div style={{
        position: 'absolute', top: 0, left: 0, right: 0, bottom: 0,
        background: 'rgba(0,0,0,0.5)', zIndex: 200,
      }} onClick={() => setActiveModal(null)}>
        <div style={{
          position: 'absolute', bottom: 0, left: 0, right: 0,
          background: colors.white, borderRadius: '24px 24px 0 0',
          maxHeight: '90%', overflowY: 'auto',
        }} onClick={e => e.stopPropagation()}>
          {/* Header */}
          <div style={{ padding: '20px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: `1px solid ${colors.grey100}` }}>
            <h2 style={{ fontSize: '18px', fontWeight: 600, color: colors.grey900, margin: 0 }}>Book Session</h2>
            <button onClick={() => setActiveModal(null)} style={{
              width: '32px', height: '32px', borderRadius: '50%',
              background: colors.grey100, border: 'none', cursor: 'pointer',
              display: 'flex', alignItems: 'center', justifyContent: 'center', color: colors.grey600,
            }}><Icons.X /></button>
          </div>

          <div style={{ padding: '24px' }}>
            {/* Provider Info */}
            <div style={{ display: 'flex', gap: '16px', marginBottom: '24px' }}>
              <div style={{
                width: '80px', height: '80px', borderRadius: '50%',
                background: selectedProvider.image, border: `3px solid ${colors.sageLight}`,
              }} />
              <div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '6px', marginBottom: '4px' }}>
                  <h3 style={{ fontSize: '18px', fontWeight: 600, color: colors.grey900, margin: 0 }}>{selectedProvider.name}</h3>
                  <span style={{ color: colors.sage }}><Icons.Check /></span>
                </div>
                <p style={{ fontSize: '14px', color: colors.grey500, margin: '0 0 8px' }}>{selectedProvider.title}</p>
                <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                  <span style={{ color: '#F59E0B' }}><Icons.Star /></span>
                  <span style={{ fontSize: '14px', fontWeight: 600, color: colors.grey700 }}>{selectedProvider.rating}</span>
                  <span style={{ fontSize: '14px', color: colors.grey500 }}>({selectedProvider.reviews} reviews)</span>
                </div>
              </div>
            </div>

            {/* Specialties */}
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px', marginBottom: '24px' }}>
              {selectedProvider.specialties.map(s => (
                <span key={s} style={{
                  background: colors.grey50, color: colors.grey600,
                  padding: '6px 12px', borderRadius: '16px', fontSize: '12px', fontWeight: 500,
                  border: `1px solid ${colors.grey150}`,
                }}>{s}</span>
              ))}
            </div>

            {/* Time Slots */}
            <h3 style={{ fontSize: '13px', fontWeight: 600, color: colors.grey700, margin: '0 0 12px', textTransform: 'uppercase', letterSpacing: '0.3px' }}>Available Times</h3>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '10px', marginBottom: '24px' }}>
              {timeSlots.map(slot => (
                <button key={slot.time + slot.date} onClick={() => setSelectedTimeSlot(slot.time)} style={{
                  background: selectedTimeSlot === slot.time ? colors.sage : colors.white,
                  border: `1px solid ${selectedTimeSlot === slot.time ? colors.sage : colors.grey200}`,
                  borderRadius: '10px', padding: '14px 8px', cursor: 'pointer', textAlign: 'center',
                }}>
                  <div style={{ fontSize: '14px', fontWeight: 600, color: selectedTimeSlot === slot.time ? colors.white : colors.grey700 }}>{slot.time}</div>
                  <div style={{ fontSize: '11px', color: selectedTimeSlot === slot.time ? 'rgba(255,255,255,0.8)' : colors.grey500, marginTop: '2px' }}>{slot.date}</div>
                </button>
              ))}
            </div>

            {/* Price */}
            <div style={{
              display: 'flex', justifyContent: 'space-between', alignItems: 'center',
              padding: '16px', background: colors.grey50, borderRadius: '12px', marginBottom: '24px',
              border: `1px solid ${colors.grey150}`,
            }}>
              <div>
                <div style={{ fontSize: '14px', color: colors.grey700 }}>Session Price</div>
                <div style={{ fontSize: '12px', color: colors.grey500 }}>45 minutes</div>
              </div>
              <div style={{ fontSize: '24px', fontWeight: 700, color: colors.grey800 }}>${selectedProvider.price}</div>
            </div>

            {/* CTA */}
            <button style={{
              width: '100%', background: colors.sage, color: colors.white,
              padding: '18px', borderRadius: '14px', border: 'none', cursor: 'pointer',
              fontSize: '16px', fontWeight: 600,
            }}>
              Book Session
            </button>
          </div>
        </div>
      </div>
    );
  };

  const CategoryModal = () => {
    if (!selectedCategory) return null;
    const categoryRoutines = routines.filter(r => r.category === selectedCategory.id || Math.random() > 0.5).slice(0, 6);
    return (
      <div style={{
        position: 'absolute', top: 0, left: 0, right: 0, bottom: 0,
        background: 'rgba(0,0,0,0.5)', zIndex: 200,
      }} onClick={() => setActiveModal(null)}>
        <div style={{
          position: 'absolute', bottom: 0, left: 0, right: 0,
          background: colors.white, borderRadius: '24px 24px 0 0',
          maxHeight: '85%', overflowY: 'auto',
        }} onClick={e => e.stopPropagation()}>
          <div style={{ padding: '20px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: `1px solid ${colors.grey100}` }}>
            <h2 style={{ fontSize: '18px', fontWeight: 600, color: colors.grey900, margin: 0 }}>{selectedCategory.name}</h2>
            <button onClick={() => setActiveModal(null)} style={{
              width: '32px', height: '32px', borderRadius: '50%',
              background: colors.grey100, border: 'none', cursor: 'pointer',
              display: 'flex', alignItems: 'center', justifyContent: 'center', color: colors.grey600,
            }}><Icons.X /></button>
          </div>
          <div style={{ padding: '20px' }}>
            <p style={{ fontSize: '14px', color: colors.grey500, margin: '0 0 20px' }}>{selectedCategory.count} routines to help you feel your best</p>
            {categoryRoutines.map(routine => (
              <div key={routine.id} style={{ marginBottom: '12px' }}>
                <RoutineCard routine={routine} size="large" />
              </div>
            ))}
          </div>
        </div>
      </div>
    );
  };

  const tabs = [
    { id: 'home', icon: Icons.Home, label: 'Home' },
    { id: 'discover', icon: Icons.Search, label: 'Discover' },
    { id: 'profile', icon: Icons.User, label: 'Profile' },
  ];

  const renderPage = () => {
    switch (currentTab) {
      case 'home': return <HomePage />;
      case 'discover': return <DiscoverPage />;
      case 'profile': return <ProfilePage />;
      default: return <HomePage />;
    }
  };

  return (
    <div style={styles.container}>
      <div style={styles.dynamicIsland} />
      <div style={styles.statusBar}>
        <span>9:41</span>
        <div style={{ display: 'flex', gap: '4px', alignItems: 'center' }}>
          <svg width="16" height="12" fill="currentColor"><rect x="0" y="3" width="3" height="9" rx="1"/><rect x="4" y="2" width="3" height="10" rx="1"/><rect x="8" y="0" width="3" height="12" rx="1"/><rect x="12" y="2" width="3" height="10" rx="1"/></svg>
          <svg width="16" height="12" fill="currentColor"><path d="M8 2C5.5 2 3.3 3.2 2 5l1 1c1-1.4 2.6-2.3 5-2.3s4 .9 5 2.3l1-1c-1.3-1.8-3.5-3-6-3z"/><path d="M8 5c-1.7 0-3.2.8-4 2l1 1c.6-.8 1.7-1.3 3-1.3s2.4.5 3 1.3l1-1c-.8-1.2-2.3-2-4-2z"/><circle cx="8" cy="10" r="2"/></svg>
          <svg width="24" height="12" fill="currentColor"><rect x="0" y="0" width="21" height="12" rx="3" stroke="currentColor" strokeWidth="1" fill="none"/><rect x="22" y="4" width="2" height="4" rx="1"/><rect x="2" y="2" width="17" height="8" rx="1.5"/></svg>
        </div>
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

      {activeModal === 'routine' && <RoutineModal />}
      {activeModal === 'player' && <PlayerModal />}
      {activeModal === 'booking' && <BookingModal />}
      {activeModal === 'category' && <CategoryModal />}
    </div>
  );
}
