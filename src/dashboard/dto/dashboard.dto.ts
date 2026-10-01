export class RecentActivityDto {
  applicantName!: string;
  id!: string;
  reference!: string;
  time!: string;
  status!: 'synced' | 'local-only';
}
class Stats {
  enrolmentsToday!: number;
  pendingSync!: number;
}
export class DashboardDto {
  stats!: Stats;
  // pendingSyncLabel!: string;
  recentActivity!: RecentActivityDto[];
}
