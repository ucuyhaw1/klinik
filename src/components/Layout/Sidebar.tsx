import React from 'react';
import { Home, Users, FileText, Stethoscope, ClipboardList, BarChart3 } from 'lucide-react';

interface SidebarProps {
  activeMenu: string;
  onMenuClick: (menu: string) => void;
}

const Sidebar: React.FC<SidebarProps> = ({ activeMenu, onMenuClick }) => {
  const menuItems = [
    { id: 'dashboard', label: 'Dashboard', icon: Home, section: 'HOME' },
    { id: 'pendaftaran-pasien', label: 'Pendaftaran Pasien', icon: ClipboardList, section: 'TRANSAKSI' },
    { id: 'pasien', label: 'Pasien', icon: Users, section: 'MASTER DATA' },
    { id: 'laporan', label: 'Laporan kunjungan', icon: BarChart3, section: 'LAPORAN' }
  ];

  const sections = ['HOME', 'TRANSAKSI', 'MASTER DATA', 'LAPORAN'];

  return (
    <div className="w-64 bg-white border-r border-gray-200 h-screen overflow-y-auto">
      <div className="p-6">
        <div className="flex items-center space-x-3">
          <div className="w-10 h-10 bg-blue-500 rounded-lg flex items-center justify-center">
            <Stethoscope className="w-6 h-6 text-white" />
          </div>
          <div>
            <h1 className="text-lg font-bold text-gray-900">PRAKTIK MANDIRI</h1>
            <p className="text-xs text-gray-500">dr. Sri Kartini Kussudiardjo, Sp.A</p>
          </div>
        </div>
      </div>

      <nav className="px-4">
        {sections.map((section) => (
          <div key={section} className="mb-6">
            <h3 className="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-3 px-3">
              {section}
            </h3>
            <div className="space-y-1">
              {menuItems
                .filter((item) => item.section === section)
                .map((item) => {
                  const Icon = item.icon;
                  const isActive = activeMenu === item.id;
                  
                  return (
                    <button
                      key={item.id}
                      onClick={() => onMenuClick(item.id)}
                      className={`w-full flex items-center space-x-3 px-3 py-2 rounded-lg text-sm font-medium transition-colors ${
                        isActive
                          ? 'bg-blue-50 text-blue-700 border-r-2 border-blue-700'
                          : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                      }`}
                    >
                      <Icon className="w-5 h-5" />
                      <span>{item.label}</span>
                    </button>
                  );
                })}
            </div>
          </div>
        ))}
      </nav>
    </div>
  );
};

export default Sidebar;